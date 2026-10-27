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

# detect reads flags from a detection buffer: draft in the input box, go phrase in the last reply, heavy band
RULE="────────────────────"
NBSP=$(printf '\302\240')
buffer() {  # $1: last reply, $2: band percent, $3: input box text
  printf '%s\n' "⏺ old reply: say \"go\"" "❯${NBSP}do it" "⏺ $1" " name @peer │ ↯  Compact soon  $2% of smart zone" "$RULE" "❯${NBSP}$3" "$RULE" "  [PONYTAIL]"
}
phrases=$(go_phrases)
check "detect nothing" "$(buffer "Done." 40 "" | detect "$phrases")" ""
check "detect draft" "$(buffer "Done." 40 "push it" | detect "$phrases")" " draft"
check "detect go" "$(buffer "Two commits. Say \"go\" and I commit." 40 "" | detect "$phrases")" " go"
check "detect go is case-insensitive" "$(buffer "SHOULD I push?" 40 "" | detect "$phrases")" " go"
check "detect go only in last reply" "$(buffer "Pushed." 40 "" | detect "$phrases")" ""
check "detect heavy at 100" "$(buffer "Done." 100 "" | detect "$phrases")" " heavy"
check "detect not heavy at 99" "$(buffer "Done." 99 "" | detect "$phrases")" ""
check "detect all" "$(buffer "Wait for my go." 137 "x" | detect "$phrases")" " draft go heavy"
check "detect no input box" "$(printf 'say go\n' | detect "$phrases")" ""

# pi: no ❯ marker, the prompt and reply share one block, the band sits below the input box
pi_buffer() {  # $1: last reply line, $2: band percent, $3: input box text
  printf '%s\n' " Say go if you agree." "$RULE" " old prompt" " r1" " r2" " r3" " $1" "" "$RULE" "$3" "$RULE" "~/.dotfiles" "○ ponytail │ pi-probe │ ↯ Compact soon $2% of smart zone"
}
check "pi detect nothing" "$(pi_buffer "Done." 40 "" | detect "$phrases")" ""
check "pi detect draft" "$(pi_buffer "Done." 40 "push it" | detect "$phrases")" " draft"
check "pi detect go" "$(pi_buffer "Say \"go\"." 40 "" | detect "$phrases")" " go"
check "pi detect go only in last lines" "$(pi_buffer "Pushed." 40 "" | detect "$phrases")" ""
check "pi detect heavy below box" "$(pi_buffer "Done." 120 "" | detect "$phrases")" " heavy"
check "claude draft on 2 lines counts once" "$(printf '%s\n' "$RULE" "❯${NBSP}line one" "  line two" "$RULE" | detect "$phrases")" " draft"
echo '{"awaits_go":["ship it"]}' >"$FLAG_FILE"
check "config phrases replace defaults" "$(CONFIG=$FLAG_FILE go_phrases)" "ship it"
: >"$FLAG_FILE"

# mark turns flags into states: go beats done and stale, heavy beats idle only, blocked never blinks
frame=$(printf 'p1 done\np2 idle\np3 working\np4 blocked\np5 stale\np6 idle')
det=$(printf 'p1 go\np2 heavy draft\np3 heavy draft\np4 draft go\np5 go heavy\np6')
check "mark" "$(mark "$frame" "$det")" "$(printf 'p1 awaits-go\np2 heavy draft\np3 working draft\np4 blocked\np5 awaits-go\np6 idle')"

# priority: blocked > awaits-go > working > done > heavy > stale > idle
check "worst awaits-go over working" "$(worst "$(printf 'p1 working draft\np2 awaits-go')")" awaits-go
check "worst blocked over awaits-go" "$(worst "$(printf 'p1 awaits-go\np2 blocked')")" blocked
check "worst done over heavy" "$(worst "$(printf 'p1 heavy\np2 done')")" done
check "worst heavy over stale" "$(worst "$(printf 'p1 stale\np2 heavy draft')")" heavy

# a draft key blinks: its colour in phase 1, dark in phase 0. The spacebar blinks too, unless the worst state is blocked.
frame=$(printf 'p1 heavy draft\np2 idle')
check "paint draft on" "$(paint "$frame" 1 2>&1 | sed -n 1p)" "set-rgb --led 0 --color #880000"
check "paint draft off" "$(paint "$frame" 0 2>&1 | sed -n 1p)" "set-rgb --led 0 --color #000000"
check "blink repaints only drafts" "$(blink "$frame" 0 2>&1)" "$(printf 'set-rgb --led 0 --color #000000\nset-rgb --led 41 --color #000000')"
check "blink nothing without drafts" "$(blink "p1 idle" 0 2>&1)" ""
check "spacebar blocked does not blink" "$(space_color "$(printf 'p1 blocked\np2 idle draft')" 0)" "#ff0000"
check "awaits-go colour" "$(state_color awaits-go)" "#00ffff"

# the spacebar counts agents past slot 12
frame=$(for i in $(seq 1 12); do echo "p$i idle"; done; echo "p13 blocked")
check "spacebar sees slot 13" "$(paint "$frame" 2>&1 | tail -1)" "set-rgb --led 41 --color #ff0000"

[ $fail -eq 0 ] && echo "ok"
exit $fail
