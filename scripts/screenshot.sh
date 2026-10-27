#!/usr/bin/env bash
# Make the README hero image.
#
# Steps:
#   1. Stage a throwaway jj repo with a fake planck-agent config.
#   2. Build a herdr workspace: the editor on the left, two pi agents stacked on the right.
#   3. Focus the workspace, bring Alacritty to the front, capture the window.
#   4. Write the PNG to $OUT.
#
# Requirements: herdr, alacritty, nvim, jj, pi, osascript, screencapture, python3.
#
# Usage: scripts/screenshot.sh [out.png]

set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-${HERE}/screenshot.png}"
STAGE="${PDE_SHOT_STAGE:-/tmp/pde-shot}"

for cmd in herdr alacritty nvim jj pi osascript screencapture python3; do
  command -v "$cmd" >/dev/null || { echo "missing command: $cmd" >&2; exit 1; }
done

# Read a key from the JSON on stdin. Path is a python expression on the "result" object.
json_get() {
  python3 -c 'import json,sys;print(eval("json.load(sys.stdin)[\"result\"]"+sys.argv[1]))' "$1"
}

focused_before="$(herdr api snapshot | python3 -c '
import json,sys
s=json.load(sys.stdin)["result"]["snapshot"]
print(next((w["workspace_id"] for w in s.get("workspaces",[]) if w.get("focused")), ""))')"

workspace=""
cleanup() {
  [[ -n "$workspace" ]] && herdr workspace close "$workspace" >/dev/null 2>&1 || true
  [[ -n "$focused_before" ]] && herdr workspace focus "$focused_before" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# 1. Stage the repo.
rm -rf "$STAGE"
mkdir -p "$STAGE/planck-agent"
(
  cd "$STAGE"
  jj git init >/dev/null
  printf '# dotfiles\n\nMy current dev environment\n' >README.md
  cat >planck-agent/config.json <<'EOF'
{
  "colors": {
    "blocked": "#ff0000",
    "awaits-go": "#00ffff",
    "working": "#ffa500",
    "done": "#0000ff",
    "heavy": "#880000",
    "idle": "#00ff00",
    "stale": "#aa00ff",
    "empty": "#202020"
  },
  "awaits_go": ["say \"go\"", "say go", "your \"go\"", "your go", "on your word", "wait for my go", "should i"],
  "keys": {
    "escape": { "keys": "esc", "color": "#ff0000" },
    "a": { "keys": "enter", "color": "#00ff00" },
    "s": { "prompt": "Continue.", "color": "#00aa00" },
    "d": { "prompt": "/clear", "color": "#ffff00" },
    "f": { "run": "planck-agent log", "color": "#ff8800" },
    "h": { "run": "planck-agent flag", "color": "#0000ff" },
    "g": { "run": "open -a Alacritty", "color": "#00ffff" },

    "z": { "macro": "Review the current diff and report only actionable findings.", "color": "#8800ff" },
    "x": { "macro": "Run the tests and fix any failures.", "color": "#8800ff" },
    "c": { "macro": "Fix the last error.", "color": "#8800ff" },
    "v": { "macro": "Propose the commit split for the current changes, then wait for my go.", "color": "#8800ff" },
    "b": { "macro": "Update the docs for this change.", "color": "#8800ff" },
    "n": { "prompt": "Summarise what you did in 3 lines.", "color": "#ff00aa" }
  }
}
EOF
  jj describe -m "feat: stage the README hero image" >/dev/null
)

# 2. Build the workspace: editor on the left, two agents stacked on the right.
created="$(herdr workspace create --cwd "$STAGE" --label pde-shot --no-focus)"
workspace="$(printf '%s' "$created" | json_get '["workspace"]["workspace_id"]')"
root="$(printf '%s' "$created" | json_get '["root_pane"]["pane_id"]')"

top="$(herdr pane split "$root" --direction right --ratio 0.40 --no-focus | json_get '["pane"]["pane_id"]')"
bottom="$(herdr pane split "$top" --direction down --ratio 0.5 --no-focus | json_get '["pane"]["pane_id"]')"

# 3. Fill the panes.
herdr pane run "$root" "nvim planck-agent/config.json" >/dev/null
herdr agent start pdeshot1 --kind pi --pane "$top" --timeout 60000 >/dev/null
herdr agent start pdeshot2 --kind pi --pane "$bottom" --timeout 60000 >/dev/null
herdr agent prompt pdeshot1 "Here is a config file excerpt:

{ \"keys\": { \"escape\": { \"keys\": \"esc\", \"color\": \"#ff0000\" }, \"a\": { \"keys\": \"enter\", \"color\": \"#00ff00\" }, \"s\": { \"prompt\": \"Continue.\", \"color\": \"#00aa00\" }, \"d\": { \"prompt\": \"/clear\", \"color\": \"#ffff00\" }, \"f\": { \"run\": \"planck-agent log\", \"color\": \"#ff8800\" }, \"h\": { \"run\": \"planck-agent flag\", \"color\": \"#0000ff\" }, \"g\": { \"run\": \"open -a Alacritty\", \"color\": \"#00ffff\" } } }

Do not run any command. Answer from this text only. List the 7 key bindings as a short markdown table with columns Key, Action, Color. Then stop." --wait --timeout 300000 >/dev/null
herdr agent prompt pdeshot2 "Here is a config file excerpt:

{ \"colors\": { \"blocked\": \"#ff0000\", \"awaits-go\": \"#00ffff\", \"working\": \"#ffa500\", \"done\": \"#0000ff\", \"heavy\": \"#880000\", \"idle\": \"#00ff00\", \"stale\": \"#aa00ff\", \"empty\": \"#202020\" } }

Do not run any command. Answer from this text only. Summarise the 8 color rules in 4 bullet points. Then stop." --wait --timeout 300000 >/dev/null
sleep 3

# 4. Capture the Alacritty window.
herdr workspace focus "$workspace" >/dev/null
osascript -e 'tell application "Alacritty" to activate' >/dev/null
sleep 3

geom="$(osascript -e 'tell application "System Events" to tell process "Alacritty" to get {position, size} of window 1')"
read -r x y w h <<<"${geom//,/ }"
screencapture -x -R "${x},${y},${w},${h}" "$OUT"

echo "Wrote ${OUT}"
sips -g pixelWidth -g pixelHeight "$OUT" | tail -2
