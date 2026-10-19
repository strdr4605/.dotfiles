#!/bin/bash
# Tests for the pure parts of bin/planck-agent: state tracking, flags, worst state, and the colours paint sends.
set -eu
cd "$(dirname "$0")"
export PLANCK_AGENT_CONFIG=config.example.json
source bin/planck-agent
FLAG_FILE=$(mktemp)
STALE_SECS=10
trap 'rm -f "$FLAG_FILE"' EXIT

fail=0
check() {
  [ "$2" = "$3" ] && return
  echo "FAIL $1"; printf '  want: %s\n  got:  %s\n' "$3" "$2"; fail=1
}

kontroll() { echo "$*" >&2; }  # paint silences stdout

# track keeps the first time it saw each pane in each status
SECONDS=100
hist=$(printf 'p1 idle\np2 working\n' | track "")
SECONDS=105
hist=$(printf 'p1 idle\np2 idle\n' | track "$hist")
check "track keeps since" "$hist" "$(printf 'p1 idle 100\np2 idle 105')"

# frame_of: flagged idle is done, idle past STALE_SECS is stale
echo p1 >"$FLAG_FILE"
SECONDS=111
check "flag beats stale" "$(frame_of "$hist")" "$(printf 'p1 done\np2 idle')"
SECONDS=116
check "stale after timeout" "$(frame_of "$hist")" "$(printf 'p1 done\np2 stale')"
: >"$FLAG_FILE"
check "unflagged goes stale" "$(frame_of "$hist")" "$(printf 'p1 stale\np2 stale')"

# worst picks the most urgent state across agents
check "worst blocked" "$(worst "$(printf 'p1 idle\np2 blocked')")" blocked
check "worst stale over idle" "$(worst "$(printf 'p1 idle\np2 stale')")" stale
check "worst empty" "$(worst "")" empty

# key_led maps a keycap to its LED: escape is first after row 1, enter is last before the spacebar
check "key_led escape" "$(key_led escape)" 12
check "key_led enter" "$(key_led enter)" 35
check "key_led unknown fails" "$(key_led nope || echo fail)" fail

# flash blinks white then restores the key colour
check "flash" "$(flash a 2>&1)" "$(printf 'set-rgb --led 13 --color #ffffff\nset-rgb --led 13 --color #00ff00')"

# paint sends one colour per LED: row 1 states, rows 2-3 key colours, then the spacebar
out=$(paint "$(printf 'p1 working\np2 stale')" 2>&1)
check "led 0 working" "$(sed -n 1p <<<"$out")" "set-rgb --led 0 --color #ffa500"
check "led 1 stale" "$(sed -n 2p <<<"$out")" "set-rgb --led 1 --color #aa00ff"
check "led 2 empty" "$(sed -n 3p <<<"$out")" "set-rgb --led 2 --color #202020"
check "led 12 escape" "$(sed -n 13p <<<"$out")" "set-rgb --led 12 --color #ff0000"
check "spacebar worst" "$(tail -1 <<<"$out")" "set-rgb --led 41 --color #ffa500"
check "led count" "$(wc -l <<<"$out" | tr -d ' ')" 37

[ $fail -eq 0 ] && echo "ok"
exit $fail
