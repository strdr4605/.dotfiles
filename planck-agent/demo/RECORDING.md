# How we record the screen and the phone

| | |
|---|---|
| Written on | 2026-10-19 |
| Written by | MiniMax-M3.1-Flash, through the pi coding agent 1.3.0 |
| Harness | `pi` 1.3.0, inside a jj repository, on macOS |

**Warning.** An LLM wrote every word in this file. The author of the repository did not write any of it. The author asked for the file, read it, asked for a rewrite, and approved it.

The facts in this file come from a real session. Every measurement, every error message and every command was run on the author's machine. The words, the order, the examples and the lessons are the work of the model.

This file tells how we make the demo takes. It tells the 7 problems we met, and what each one taught us.

## Explain like I am 5

Imagine you film your desk. You put a camera above it, and you film your hands on a small keyboard. You also want the text on your computer screen in the same video. So you have 2 cameras. One is in the computer. One is on the desk.

Now comes the hard part. The 2 cameras do not wake up at the same time. The camera in the computer needs 2 seconds before it sends a picture. So when you press a key, the text appears on the screen, but the film of your hands has already moved on. The 2 pictures are out of step.

We fix this with a number. The number says how many seconds the desk picture must wait for the computer picture. The computer reads that number from the log of the recording. So the number is always right.

That is the whole idea. The rest of this file is the story of how we got there.

## What a take must show

Each take shows 2 pictures at the same time:

- the screen, with the terminal in it
- the Planck keyboard, filmed by the phone

The keyboard picture sits in the bottom right corner of the screen picture. It is 480 by 270 pixels, in a frame of 1280 by 720. So it takes 37 percent of the width.

The take is 2 files. A movie, for the post. A gif, for the article.

## The story

### 1. The first take lost its first seconds

We made a take. The movie started 3 or 4 seconds late. The hand was already moving, but the screen showed nothing. We had pressed the key, and the recording missed it.

We looked for the cause. The log said the device was ready. The log was true, and it was not enough.

The screen device opens at once. It sends the first picture 2 seconds later. The first pictures are black. Our script sent the signal at the moment the device opened. So the signal came 2 seconds before the screen was really live. The user acted on the signal, and those 2 seconds fell off the front of the movie.

The fix was to wait for a picture, not for a device. We look for a frame count in the log:

```
grep -q 'frame= *[1-9]' screen.log
```

The lesson: a line that says "ready" is not always a picture.

### 2. Two devices in one process were too slow

We wanted one command for the whole take. So we gave one ffmpeg process 2 inputs. It read the screen. It read the phone. It put the phone over the screen.

The process ran at 0.66 times the real time. It lost a third of every take. The keyboard picture jumped.

We measured each part on its own.

| Process | Speed | Verdict |
|---|---|---|
| Screen only, 15 fps, nv12, ultrafast | 0.99 times | real time |
| Phone only, 30 fps, ultrafast | 0.99 times | real time |
| Both in one process | 0.66 times | too slow |

2 capture devices in one process fight for the machine. 2 processes do not.

So the phone and the screen run apart from each other now. Each one writes its own file. Then we join the 2 files with a third command. That command runs at 91 times the real time, so it costs nothing.

The lesson: measure each part alone. The sum of 2 fast parts is not always a fast whole.

### 3. The 2 files did not agree on the time

Now the movie had no jump. But the hand moved before the terminal reacted. The 2 files were out of step.

Each recorder puts a time on its first frame. The screen and the phone did not agree on that time. The difference was 1.4 seconds in one test, 2.7 in the next, and 8.7 in the last.

The screen is often late, because it needs 2 seconds for its first frame. The phone is quick.

We read the 2 times from the log files. Then we give the phone an offset:

```
offset = phone_start - screen_start
```

We put that offset on the phone input:

```
ffmpeg -i screen.mov -itsoffset -8.660 -i phone.mov ...
```

The offset puts the phone picture back on top of the screen picture. The number changes with every take. We read it, we never hardcode it.

The lesson: the offset is a fact about this take, not a fact about the world.

### 4. The keyboard arrived upside down

The phone sent the picture upside down. The ESC key sat on the right. The letters were upside down.

We tried `transpose=2` first. That made it worse. `transpose=2` is a 90 degree turn counter clockwise. It is not the 180 degree turn we wanted.

The answer is `hflip,vflip`. We proved it by putting all 4 turns next to each other in one picture. Only one of them read the right way up.

The phone also sees the whole desk. The laptop, the cable, the wall. So we crop the picture to the keyboard. The crop lives at the top of `common.sh`:

```
RECORD_PHONE_FILTER="hflip,vflip,crop=900:506:840:480,fps=15,scale=480:270"
```

The lesson: turn the picture first, then crop it. And check the turns with a picture, not with your head.

### 5. A second press started a second pair of recorders

We pressed the start key twice. The second press made a second phone and a second screen. Then 2 ffmpeg processes wrote the same file, and the movie was broken.

The cause was a race. `record-start` slept for 3 seconds before it wrote the lock file. A second press in that time found no lock, so it went ahead.

The fix is simple. The lock file comes first, before any sleep. Now a second press says "a recording is already running".

The lesson: take the lock before you wait. A lock that comes late is no lock.

### 6. A leftover recorder held the device

Sometimes the screen recorder never started. The log stopped at this line, and said nothing more:

```
[AVFoundation indev] Configuration of video device failed, falling back to default.
```

The reason was another ffmpeg process. It still held the capture device. The new recorder waited for it, forever. It did not report an error. It sat there and waited.

The fix is to kill every recorder before you start a new one. `record-start` does this with `pkill -f 'ffmpeg.*avfoundation'`, and then again with `-9`.

The lesson: a hang without an error is usually a device that is still in use.

### 7. The notification never came

We sent a banner to tell the user that the screen was live. The user never saw it. They waited, and nothing came.

The cause was the parent process. macOS drops a notification from an orphan. `osascript` returns 0, and no banner appears. The parent must still be alive.

Our script ran the notification in the background. The background part had no parent, because the script had already left.

We moved the notification to the front of the script. Then we added 2 more signals, because a banner is never a sure thing. Now the user gets a sound, a blink of the `L` key on the Planck, a banner, and a line in the terminal.

The lesson: a signal on the screen is not a signal. Use 2 senses.

## How it works now

### The order of the work

`record-start` does this:

1. Take the lock. Refuse a second take.
2. Kill every old recorder.
3. Start the phone. Wait for its device to open.
4. Wait 3 seconds.
5. Start the screen. Wait for the first picture.
6. Write the process ids and the start times into the lock file.
7. Give the signal.

The script returns in about 10 seconds. The recorders keep running.

The phone must start first. The screen needs 2 seconds for its first picture, and the phone gives it that head. The phone must also record longer than the screen. The rule is:

```
phone_length >= screen_length + (screen_start - phone_start)
```

Both recorders stop at the same moment. The phone started earlier, so the phone is long enough. We keep the phone alive 2 seconds after the screen, to be safe.

`record-stop` does this:

1. Wait for the lock file to hold the real process ids.
2. Kill the screen.
3. Wait 2 seconds.
4. Kill the phone.
5. Read the 2 start times.
6. Build the movie with the offset.
7. Build the gif.
8. Remove the lock file.

### The signals

| Signal | Where it comes from | Why |
|---|---|---|
| A sound | `/System/Library/Sounds/Tink.aiff` | It always works. |
| A blink | The `L` key turns red 3 times | The user looks at the keyboard. The phone films it. |
| A banner | `osascript` | It is nice, but macOS often drops it. |
| A line | The terminal | It is always there. |

A banner is the worst of the 4. Use it, but do not wait for it.

## The recipe

Record with a fixed time:

```
planck-demo record 16 /tmp/gif2
```

Record with the Planck keys:

```
planck-demo record-start   # or press Hyper+P
planck-demo record-stop    # or press Hyper+O
```

The keys are not in the daily `config.json`. Add them when you record:

```json
"l": { "run": "$HOME/.dotfiles/planck-agent/demo/record-start", "color": "#dddd00" },
"k": { "run": "$HOME/.dotfiles/planck-agent/demo/record-stop", "color": "#dddd00" }
```

The keycaps need no change in `skhdrc`.

## What you must know to maintain this

**The phone gives only 30 fps.** If you ask for 15, ffmpeg says:

```
Selected framerate (15.000000) is not supported by the device.
Error opening input: Input/output error.
```

This error is not about permissions. Read the first line, not the last.

**The screen wants nv12.** The default yuv420p is not supported. Use `-pixel_format nv12` for the screen, and nothing for the phone.

**A device line is not a picture.** `Duration: N/A, start:` means the device opened. The picture comes about 2 seconds later. Wait for a frame count.

**One writer per file.** 2 ffmpeg processes on one output file make a broken movie. The lock file stops a second take, and the `pkill` stops an old one.

**A leftover recorder holds the device.** The new recorder then waits without an error. Kill them all before you start.

**The offset is not a constant.** Read it from the logs, every time. Do not hardcode it.

**The phone must start first.** If it starts later than the screen picture, the first seconds have no keyboard.

**The crop follows the phone.** The numbers in `RECORD_PHONE_FILTER` fit the place where the phone lies now. Move the phone, and change them.

**The screen shows everything.** The capture takes the whole display, including the browser. Put the terminal in front, or crop the screen branch.

**A large file needs a larger limit.** jj refuses a new file above 1 MiB. The takes live in the blog repo, which has:

```
jj config set --repo snapshot.max-new-file-size 10485760
```

**The gif is big.** A 30 second take gives about 8 MB. Cut the take down before you publish it.

## The commands we use

Read the device list before you change a device number:

```
ffmpeg -f avfoundation -list_devices true -i ""
```

Record one device, and measure the speed:

```
ffmpeg -f avfoundation -framerate 15 -pixel_format nv12 -i "4:none" \
  -vf "scale=1280:720" -preset ultrafast -r 15 -t 5 /tmp/screen.mov
```

Join the 2 files, with the offset:

```
ffmpeg -i /tmp/screen.mov -itsoffset -8.660 -i /tmp/phone.mov \
  -filter_complex "[1:v]scale=480:270[ph];[0:v]scale=1280:720[sc];[sc][ph]overlay=800:450:eof_action=pass" \
  -preset ultrafast -r 15 /tmp/combined.mov
```

Build the gif, with a small palette:

```
ffmpeg -i /tmp/combined.mov -vf "fps=12,scale=580:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" /tmp/out.gif
```

Check one picture, without making a movie:

```
ffmpeg -i /tmp/combined.mov -vf "select=eq(n\,60),scale=800:-1" -vframes 1 -update 1 /tmp/frame.png
```

## Conclusion

This job had 5 parts: 2 cameras, 1 clock, 1 file lock, and 1 signal. Each part failed in a way that the log did not explain.

The work was not in the commands. The commands are 4 lines long, and they are in this file. The work was in the question after each failure. Why is this process slow? Why is this picture turned? Why is this device busy? Why is this banner silent? Why does the movie start late? Each question needed 1 measurement, and the measurement gave the answer.

All 5 failures were silent. No tool said that it was wrong. The slow process ran and produced a file. The turned picture looked like a picture. The busy device waited without an error. The orphan process returned 0. The early signal looked like a good signal. A silent failure is much harder than a loud one. The only way through it is to write down what you expect, and then to look for the difference.

Each fix is a rule, not a trick. One device per process. One writer per file. Read the offset from the log. Wait for a picture, not for a device. Kill the old recorders first. Use 2 senses for the signal. A rule is small, and it holds for the next take. A trick only holds for the one.

The 2 people in this session did different work. The model measured, changed, tested and wrote. The author chose the plan, judged every take, and decided what the keys and the lights must mean. The model could not tell that a take was good. The author could not write the file alone. The result needed both, and the parts came from both.

What remains at the end is not a video. It is 2 files, 8 rules, and a keyboard that still works on Monday. The rules are the real product. The next person can change the phone, the crop, the length of the take, or the whole camera, and the rules still hold.
