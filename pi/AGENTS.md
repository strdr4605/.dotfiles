# Tmux Window Management

When running inside a tmux session, automatically manage the window name:

- Always use "pi" prefix followed by 2-3 words separated by dashes
- Keep names concise and descriptive of the current work
- Use the command: `tmux rename-window "name-here"`
- Update the window name when:
  - Session starts (set to "pi")
  - Topic changes significantly
  - After `/new` or context switch
  - Every ~10 user prompts if topic is ongoing
- Default/fallback name: "pi"
- Examples: "pi-fixing-auth", "pi-exploring-code", "pi-blog-post"

## Active Extensions

- **tmux-window**: Manages tmux window naming automatically
  - Session start: renames to `pi-<project>` (e.g., `pi-dotfiles`)
  - Session end: restores to `zsh`
  - Every 10 turns: updates name if context changed significantly (shows `*` briefly)
