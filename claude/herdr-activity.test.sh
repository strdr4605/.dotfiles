#!/bin/sh
# Self-check for bin/claude-herdr-activity: feed hook JSON, decode the record. Run: sh claude/herdr-activity.test.sh
set -eu
out=$(mktemp)
run() { : > "$out"; printf '%s' "$1" | HC_TERMINAL_ID=t0 HERDR_ACTIVITY_TTY="$out" "$HOME/.dotfiles/bin/claude-herdr-activity"; }
decode() { { tr -d '\033\\' < "$out"; echo; } | sed -E 's/.*title=([^:]+):msg=(.*)/\1 \2/' | { read -r t m; printf '%s|%s\n' "$(printf %s "$t" | base64 -d)" "$(printf %s "$m" | base64 -d)"; }; }
check() { got=$(decode); [ "$got" = "$1" ] || { echo "FAIL: want '$1' got '$got'"; exit 1; }; echo "ok  $1"; }

run '{"hook_event_name":"PreToolUse","tool_name":"Read","cwd":"/repo","tool_input":{"file_path":"/repo/src/kit.js"}}'; check 'read|Reading src/kit.js'
run '{"hook_event_name":"PreToolUse","tool_name":"Bash","cwd":"/repo","tool_input":{"command":"npm test","description":"Run the tests"}}'; check 'run|Run the tests'
run '{"hook_event_name":"PreToolUse","tool_name":"Bash","cwd":"/repo","tool_input":{"command":"npm test\nrm x"}}'; check 'run|Running npm test'
run '{"hook_event_name":"PreToolUse","tool_name":"Edit","cwd":"/repo","tool_input":{"file_path":"a.ts"}}'; check 'edit|Editing a.ts'
run '{"hook_event_name":"PreToolUse","tool_name":"Glob","cwd":"/repo","tool_input":{"pattern":"**/*.ts"}}'; check 'search|Finding **/*.ts'
run '{"hook_event_name":"PreToolUse","tool_name":"mcp__x__y","cwd":"/repo","tool_input":{}}'; check 'tool|Using mcp__x__y'
peer() { { tr -d '\033\\' < "$out"; echo; } | sed -nE 's/.*id=peer:title=([^:]+):msg=([^]]*)\]7501.*/\1 \2/p' | { read -r t m; printf '%s|%s\n' "$(printf %s "$t" | base64 -d)" "$(printf %s "$m" | base64 -d)"; }; }
run '{"hook_event_name":"PreToolUse","tool_name":"Bash","cwd":"/repo","tool_input":{"command":"hc wait --timeout 600 t3","description":"Wait for the reviewer"}}'; [ "$(peer)" = "wait|t3" ] && echo "ok  peer wait|t3" || { echo "FAIL peer: $(peer)"; exit 1; }
run '{"hook_event_name":"PreToolUse","tool_name":"Bash","cwd":"/repo","tool_input":{"command":"hc wait --children"}}'; [ "$(peer)" = "wait|children" ] && echo "ok  peer wait|children" || { echo "FAIL peer: $(peer)"; exit 1; }
run '{"hook_event_name":"PostToolUse","tool_name":"Read"}'; [ "$(cat "$out")" = "$(printf '\033]7501;state=clear:id=peer\033\\\033]7501;state=clear:id=activity\033\\')" ] && echo "ok  clear" || { echo "FAIL clear"; exit 1; }
run 'not json'; [ ! -s "$out" ] && echo "ok  bad input writes nothing"
: > "$out"; printf '{}' | env -u HC_TERMINAL_ID HERDR_ACTIVITY_TTY="$out" "$HOME/.dotfiles/bin/claude-herdr-activity"; [ ! -s "$out" ] && echo "ok  outside Herdr writes nothing"
