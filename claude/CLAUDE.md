@RTK.md
@../agents/AGENTS.md

# Local tools

- `slack-latest [hours] [-n]`: print recent Slack messages (channels, DMs, threads) as plain text. Default is 24 hours. `-n` skips the fetch. Read-only. Use it when I ask about Slack.
- `pr-resume <PR>`: reopen the Claude sessions listed in the PR body `author-sessions` block. A live session gets focus (hc: prints its terminal). Each other session resumes in a new Herdr tab (hc: a new terminal `pr-<PR>-<role>`). Run it inside Herdr or an hc terminal.

# PR author-sessions note

When you create a PR, or push changes to an open PR, keep this hidden block at the end of the PR body, before the generated-with footer:

```markdown
<!-- author-sessions
updated: <YYYY-MM-DD>
main:   <session-id>  dir: <cwd, with ~ for $HOME>  # <what this session did>
herdr:  <session-id>  dir: <cwd, with ~ for $HOME>  # <what this agent did>
-->
```

- `main` is your own session. Get the ID with `herdr agent get "$HERDR_PANE_ID" | jq -r '.result.agent.agent_session.value'`.
- In hc (`HC_TERMINAL_ID` is set, for example on the agents VM), use this command: `jq -r .sessionId ~/.claude/sessions/$(hc get "$HC_TERMINAL_ID" --json | jq -r .foreground.pid).json`.
- Add one `herdr` line for each Herdr or hc agent that you started or prompted for this PR. Get its ID the same way with its agent name, pane ID or terminal address. Herdr: dir from `.result.agent.cwd`. hc: dir from `.cwd` of `hc get`.
- Do not add subagents. They resume with the main session.
- On an update, keep the existing lines, add the new ones, and change `updated`.
- When you edit the PR body for other reasons (for example a recap skill), keep this block.
- If an ID is empty, write `main: unknown` (or `herdr: unknown`) and tell me. Do not guess an ID.
- `pr-resume` parses this block. Keep the line format exact: one ID, `dir:`, one path without spaces.
