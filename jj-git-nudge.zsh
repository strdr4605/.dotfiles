# jj git-command nudge
# ---------------------------------------------------------------------------
# `jjgit <git command>` asks headless Claude (haiku) for the jj equivalent,
# tailored to the workspace's live jj state (status/log/workspaces/bookmarks).
# Standalone command — does not wrap/override `git`, so no recursion risk.
#
# Usage:      jjgit checkout -b foo
# Disable:    export JJ_GIT_NUDGE=0
# Pick Claude model: export JJ_SUGGEST_MODEL=haiku   (default)
# Pick pi model for jjaskp: export JJASKP_MODEL=minimax/MiniMax-M3

: ${JJ_SUGGEST_MODEL:=haiku}
: ${JJASKP_MODEL:=minimax/MiniMax-M3}
: ${JJ_GIT_NUDGE:=1}

# Shared: print a unified workspace snapshot the LLM can reason about.
_jjask_context() {
  print -r -- '## jj status';         command jj st 2>&1
  print -r -- '## jj log (recent)';   command jj log -n 12 2>&1
  print -r -- '## jj workspace list'; command jj workspace list 2>&1
  print -r -- '## jj bookmarks';      command jj bookmark list 2>&1
}

_jjask_disabled_check() {
  local label="$1"
  if [[ "$JJ_GIT_NUDGE" == 0 ]]; then
    print -u2 "${label}: disabled (JJ_GIT_NUDGE=0)"; return 1
  fi
  return 0
}

jjgit() {
  if [[ "$JJ_GIT_NUDGE" == 0 ]]; then
    print -u2 "jjgit: disabled (JJ_GIT_NUDGE=0)"; return 1
  fi

  if [[ $# -eq 0 ]]; then
    print -u2 "usage: jjgit <git command...>   (e.g. jjgit checkout -b foo)"; return 1
  fi

  if ! command -v claude >/dev/null 2>&1; then
    print -u2 "jjgit: claude CLI not found"; return 1
  fi

  local jjroot; jjroot="$(command jj root 2>/dev/null)"
  if [[ -z "$jjroot" ]]; then
    print -u2 "jjgit: not inside a jj workspace"; return 1
  fi

  local gitcmd="git ${(j: :)@}"
  print -u2 -P "%F{yellow}jjgit ⇢ translating \`${gitcmd}\` to jj (a few seconds)…%f"

  local ctx
  ctx="$(
    print -r -- '## jj status';         command jj st 2>&1
    print -r -- '## jj log (recent)';   command jj log -n 12 2>&1
    print -r -- '## jj workspace list'; command jj workspace list 2>&1
    print -r -- '## jj bookmarks';      command jj bookmark list 2>&1
  )"

  # </dev/null critical — `claude -p` reads stdin, else blocks on terminal.
  command claude -p \
    --model "$JJ_SUGGEST_MODEL" \
    --output-format text \
    --append-system-prompt 'You are a Jujutsu (jj) expert helping a git user learn jj. The user typed a git command and wants the jj equivalent. Reply with the exact command(s) in a fenced code block, then a one-line reason for each. Keep it under ~8 lines, no preamble, no closing remarks. If there is no clean equivalent, say so briefly and give the closest jj workflow. Target jj 0.43+ and use CURRENT commands only: prefer `jj new`/`jj edit` (never the deprecated `jj checkout`), `jj bookmark` (not `jj branch`), `jj git fetch`/`jj git push`, `jj describe`/`jj squash`; remote branches are bookmarks like `master@origin`. Do NOT call any tools; answer only from the provided context.' \
    "I want to run \`${gitcmd}\`. Here is my current jj state:

${ctx}

What's the equivalent in jj?" </dev/null
}

# jjaskc <question> — ask Claude (headless).
# Usage: jjaskc "how do I split my current change into two commits"
jjaskc() {
  _jjask_disabled_check jjaskc || return 1

  if [[ $# -eq 0 ]]; then
    print -u2 "usage: jjaskc <question...>   (e.g. jjaskc how do I split this change in two)"; return 1
  fi

  if ! command -v claude >/dev/null 2>&1; then
    print -u2 "jjaskc: claude CLI not found"; return 1
  fi

  local jjroot; jjroot="$(command jj root 2>/dev/null)"
  if [[ -z "$jjroot" ]]; then
    print -u2 "jjaskc: not inside a jj workspace"; return 1
  fi

  local question="${(j: :)@}"
  print -u2 -P "%F{yellow}jjaskc ⇢ asking Claude ($JJ_SUGGEST_MODEL) (a few seconds)…%f"

  local ctx; ctx="$(_jjask_context)"

  # </dev/null critical — `claude -p` reads stdin, else blocks on terminal.
  command claude -p \
    --model "$JJ_SUGGEST_MODEL" \
    --output-format text \
    --append-system-prompt 'You are a Jujutsu (jj) expert helping a user accomplish a task in jj. Reply with concrete jj command(s) in a fenced code block, then brief reasoning. Keep it under ~12 lines, no preamble, no closing remarks. Target jj 0.43+ and use CURRENT commands only: prefer `jj new`/`jj edit` (never the deprecated `jj checkout`), `jj bookmark` (not `jj branch`), `jj git fetch`/`jj git push`, `jj describe`/`jj squash`; remote branches are bookmarks like `master@origin`. Do NOT call any tools; answer only from the provided context.' \
    "I want to: ${question}

Here is my current jj state:

${ctx}

What should I do?" </dev/null
}

# jjaskp <question> — ask pi (minimax/MiniMax-M3 by default).
# Usage: jjaskp "how do I split my current change into two commits"
jjaskp() {
  _jjask_disabled_check jjaskp || return 1

  if [[ $# -eq 0 ]]; then
    print -u2 "usage: jjaskp <question...>   (e.g. jjaskp how do I split this change in two)"; return 1
  fi

  if ! command -v pi >/dev/null 2>&1; then
    print -u2 "jjaskp: pi CLI not found"; return 1
  fi

  local jjroot; jjroot="$(command jj root 2>/dev/null)"
  if [[ -z "$jjroot" ]]; then
    print -u2 "jjaskp: not inside a jj workspace"; return 1
  fi

  local question="${(j: :)@}"
  print -u2 -P "%F{yellow}jjaskp ⇢ asking pi ($JJASKP_MODEL) (a few seconds)…%f"

  local ctx; ctx="$(_jjask_context)"

  # --no-tools keeps this a pure Q&A call; --no-session avoids one session per question.
  command pi -p \
    --no-tools \
    --no-session \
    --no-context-files \
    --model "$JJASKP_MODEL" \
    --append-system-prompt 'You are a Jujutsu (jj) expert helping a user accomplish a task in jj. Reply with concrete jj command(s) in a fenced code block, then brief reasoning. Keep it under ~12 lines, no preamble, no closing remarks. Target jj 0.43+ and use CURRENT commands only: prefer `jj new`/`jj edit` (never the deprecated `jj checkout`), `jj bookmark` (not `jj branch`), `jj git fetch`/`jj git push`, `jj describe`/`jj squash`; remote branches are bookmarks like `master@origin`. Do NOT call any tools; answer only from the provided context.' \
    "I want to: ${question}

Here is my current jj state:

${ctx}

What should I do?" </dev/null
}
