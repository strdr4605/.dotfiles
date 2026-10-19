# Shared settings for the planck-agent demo helpers.
# Sourced by bootstrap, stage, cue, reset, and smoke.

DEMO_ROOT="${PLANCK_DEMO_ROOT:-/tmp/planck-demo}"
DEMO_LABEL="${PLANCK_DEMO_LABEL:-planck-demo}"
STATE_FILE="${DEMO_ROOT}/state.env"
ROSTER_FILE="${DEMO_ROOT}/ROSTER.md"

# The sandbox projects. Each one holds one demo agent.
SANDBOX_HELLO="${DEMO_ROOT}/hello-5-styles"
SANDBOX_LINT="${DEMO_ROOT}/fix-lint"
SANDBOX_SUMMARISE="${DEMO_ROOT}/summarise"

# Long task for the pi sandbox agent. It keeps the LED orange for about 25 seconds.
# Cue it about 20 seconds before the shot, so the LED turns blue during the shot.
TASK_LONG="Write a guide called 'Five ways to say hello'. Give each of the five styles its own section with a short example. Keep the total under 700 words."

# Short task for the opencode sandbox agent.
TASK_SHORT="Read README.md in this repository. Then list three things the demo needs. Do not change any file."

# Print the agent slot table: slot, backend, state, project.
agent_slots() {
  herdr agent list | jq -r '.result.agents | to_entries[] | "\(.key + 1)\t\(.value.agent)\t\(.value.agent_status)\t\(.value.cwd)"'
}

# Capture settings. The screen device needs about 2 seconds before it sends its
# first frame. The phone sends its first frame at once. So the phone starts
# first and gets the head that the screen lacks.
RECORD_SCREEN_DEVICE=4
RECORD_PHONE_DEVICE=3
RECORD_SCREEN_FILTER="scale=1280:720"
RECORD_PHONE_FILTER="hflip,vflip,crop=900:506:840:480,fps=15,scale=480:270"
RECORD_PHONE_LEAD=3
RECORD_STATE="${DEMO_ROOT}/record.state"

# The phone goes in the bottom right corner. The top right corner belongs to
# the macOS notification, which tells the user that the screen is live.
RECORD_PHONE_X=800
RECORD_PHONE_Y=450

# The LED of the "l" key, which starts the recording. The script blinks it
# when the screen goes live.
RECORD_START_LED=21
RECORD_SOUND=/System/Library/Sounds/Tink.aiff

# Blink the Planck, so the user sees that the screen is live. The user looks
# at the keyboard, and the phone camera films it.
record_signal() {
  export PATH="$HOME/.cargo/bin:$PATH"
  afplay "$RECORD_SOUND" >/dev/null 2>&1 || true
  for _ in 1 2 3; do
    kontroll set-rgb --led "$RECORD_START_LED" --color "#ff0000" >/dev/null 2>&1 || true
    sleep 0.15
    kontroll set-rgb --led "$RECORD_START_LED" --color "#dddd00" >/dev/null 2>&1 || true
    sleep 0.15
  done
  osascript -e 'display notification "The screen is live. Act now." with title "planck-demo"' >/dev/null 2>&1 || true
}
