# planck-agent demo

Helpers that put herdr and the Planck LED row into a fixed state, so you can record the demo without surprises.

| Script | Does |
|---|---|
| `bootstrap` | creates the sandbox projects in `/tmp/planck-demo` |
| `stage` | starts the demo agents in herdr and writes the roster |
| `precheck` | reports the slot table, and focuses the real agents, so they do not turn stale |
| `cue` | gives a sandbox agent a task, so its LED changes on cue |
| `reset` | stops the demo agents and leaves your real agents alone |
| `smoke` | runs `stage` and `reset` end to end, without recording |
| `record` | captures the screen and the phone for a fixed time, then builds one gif |
| `record-start` | begins a take, and waits for the stop key |
| `record-stop` | ends the take, and builds the gif |

Run them through the dispatcher:

```
planck-demo stage
```

Link it once:

```
ln -sf $HOME/.dotfiles/planck-agent/demo/planck-demo ~/.local/bin/planck-demo
```

## The slot table

The Planck row 1 shows the agents in herdr order. The demo uses five slots.

| Slot | Backend | Project | Who |
|---|---|---|---|
| 1 | pi | your first real project | real agent, it shows its real state |
| 2 | opencode | your second real project | real agent, it shows its real state |
| 3 | pi | `hello-5-styles` | sandbox, orange during the demo |
| 4 | opencode | `fix-lint` | sandbox, green, then blue |
| 5 | pi | `summarise` | sandbox, you start it on camera |

`stage` writes the live table to `/tmp/planck-demo/ROSTER.md`.

The states of slots 1 and 2 do not matter. The shot shows what your real agents actually do.

## The Planck keys

Hyper means ctrl+alt+shift+cmd. The agent layer is layer 5.

| Shot | Key | Effect |
|---|---|---|
| focus a slot | Hyper+1 … Hyper+5 | focus that agent and raise the terminal |
| jj side panes | Hyper+T | open or close `jj log` and `jj status` |
| macro | Hyper+S | type the review prompt, do not submit it |
| approve | Hyper+W | type the approve prompt and submit it |
| flag | Hyper+U | paint the focused agent blue, so you know you saw it |
| record start | Hyper+P | begin the take |
| record stop | Hyper+O | end the take, and build the gif |

The keys are in `config.json`, so they work with skhd and with Raycast. They need no change in `skhdrc`.

## Recording with the Planck

Press Hyper+P to begin a take. The phone starts at once, and the screen follows 3 seconds later. The screen device needs about 2 seconds before it sends its first frame, so the screen goes live about 5 seconds after the press.

The signal comes in three ways, because the macOS banner does not always show:

- a sound, from `/System/Library/Sounds/Tink.aiff`
- the `L` key blinks red three times on the Planck
- a notification, and a line in the terminal

Act when the signal comes. Then press Hyper+O to end the take. The helper builds the movie and the gif, and shows where they are.

`record-start` kills every leftover recorder first. A recorder that holds the capture device makes the next one wait forever.

## The two shots

**GIF 1, the control deck, 12 s**

1. Hyper+1, Hyper+2, Hyper+3. The terminal jumps between agents.
2. Hyper+T twice. The jj log and jj status panes open and close.
3. Hyper+S. The macro text lands in the input box. The LED stays green.
4. Hyper+W. The approve text submits. The LED turns orange.

**GIF 2, the LED row and the new agent, 16 s**

1. Hold on the LED row.
2. In the `summarise` tab, type `pi` and press Enter. Slot 5 appears.
3. Type `Summarise this repo in 3 bullets.` and press Enter. Slot 5 turns orange.
4. Slot 5 and slot 3 turn blue when their tasks end. Slot 4 turns blue with Hyper+4, then Hyper+U.

The prompt in step 3 takes about 9 seconds. It needs to fit inside the shot, or the flip lands after the cut.

## Recording from the shell

```
planck-demo record 12 /tmp/gif1
```

It records the screen and the phone at the same time, puts the phone in the bottom right corner of the screen, and writes `/tmp/gif1.mov` and `/tmp/gif1.gif` at 580 px wide.

The phone is the iPhone as a Continuity Camera. Point it down at the Planck, with the desk dark. The helper turns the phone video the right way up, crops it to the keyboard, and shows it at 480 by 270 pixels, which is 37 percent of the frame width.

The phone starts 3 seconds before the screen. The helper prints `screen recorder is live, act now` when the first frame is encoded, and gives the same signal as the Planck keys.

## The runbook

```
planck-demo bootstrap     # once per reboot, /tmp is volatile
planck-demo stage
planck-demo precheck      # shows the row, and keeps the real agents fresh
```

Record GIF 1. Then, in a second terminal, run `planck-demo cue pi` and start GIF 2 right after. The task takes about 10 seconds, so slot 3 turns blue near the end of the shot. If the flip lands too early, cue again and take it again.

After the take:

```
planck-demo reset
```

`reset` closes the demo workspace, and stops a running recording. It never touches your real projects.

## Before you record

- Bring the terminal to the front. The recording captures whatever is on screen.
- The two real agents show your real project when you focus them. Scroll them to a harmless spot, or close their tabs, if you do not want that on camera.
- The Planck must sit on layer 5, otherwise the LED row shows the Oryx colours.
- The LED row turns purple after 10 minutes of idle. `precheck` focuses the real agents, so they count as seen. Run it again right before the take.

## The recorded takes

The takes live in the blog repo, because the blog post uses them. They are in `public/` there:

| File | What |
|---|---|
| `planck-agent-1.gif` | the control deck shot |
| `planck-agent-1.mov` | the master of the first take, for re-encoding |
| `planck-agent-2.gif` | the LED row shot, with the agent added on camera |
| `planck-agent-2.mov` | the master of the second take, for re-encoding |

The gif files are 580 px wide and 12 frames per second. The movies are the masters, so you can cut a shorter gif from them later.

## Notes

- The sandbox projects use `jj git init`, so `jj log` and `jj status` work in them.
- `planck-agent flag` paints an idle agent blue. The flag clears when you focus the agent again, or when the agent starts working.
- The gif is 580 px wide, which suits the blog. A 30 second take gives a gif of about 8 MB. Cut the take down before you publish it.
