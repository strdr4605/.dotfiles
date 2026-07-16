# jj git-command nudge
# ---------------------------------------------------------------------------
# `jjgit <git command>` asks headless Claude (haiku) for the jj equivalent,
# tailored to the workspace's live jj state (status/log/workspaces/bookmarks).
# Standalone command — does not wrap/override `git`, so no recursion risk.
#
# Usage:      jjgit checkout -b foo
# Disable:    export JJ_GIT_NUDGE=0
# Pick model: export JJ_SUGGEST_MODEL=haiku   (default)

: ${JJ_SUGGEST_MODEL:=haiku}
: ${JJ_GIT_NUDGE:=1}

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

# jjask <free-form question> — for when a single command isn't enough;
# describe intent, get jj guidance grounded in live workspace state.
# Usage: jjask "how do I split my current change into two commits"
jjask() {
  if [[ "$JJ_GIT_NUDGE" == 0 ]]; then
    print -u2 "jjask: disabled (JJ_GIT_NUDGE=0)"; return 1
  fi

  if [[ $# -eq 0 ]]; then
    print -u2 "usage: jjask <question...>   (e.g. jjask how do I split this change in two)"; return 1
  fi

  if ! command -v claude >/dev/null 2>&1; then
    print -u2 "jjask: claude CLI not found"; return 1
  fi

  local jjroot; jjroot="$(command jj root 2>/dev/null)"
  if [[ -z "$jjroot" ]]; then
    print -u2 "jjask: not inside a jj workspace"; return 1
  fi

  local question="${(j: :)@}"
  print -u2 -P "%F{yellow}jjask ⇢ asking (a few seconds)…%f"

  local ctx
  ctx="$(
    print -r -- '## jj status';         command jj st 2>&1
    print -r -- '## jj log (recent)';   command jj log -n 12 2>&1
    print -r -- '## jj workspace list'; command jj workspace list 2>&1
    print -r -- '## jj bookmarks';      command jj bookmark list 2>&1
  )"

  command claude -p \
    --model "$JJ_SUGGEST_MODEL" \
    --output-format text \
    --append-system-prompt 'You are a Jujutsu (jj) expert helping a user accomplish a task in jj. Reply with concrete jj command(s) in a fenced code block, then brief reasoning. Keep it under ~12 lines, no preamble, no closing remarks. Target jj 0.43+ and use CURRENT commands only: prefer `jj new`/`jj edit` (never the deprecated `jj checkout`), `jj bookmark` (not `jj branch`), `jj git fetch`/`jj git push`, `jj describe`/`jj squash`; remote branches are bookmarks like `master@origin`. Do NOT call any tools; answer only from the provided context.' \
    "I want to: ${question}

Here is my current jj state:

${ctx}

What should I do?" </dev/null
}
