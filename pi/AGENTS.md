# Conventional Commits

Use [Conventional Commits](https://www.conventionalcommits.org) format for all commit messages:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change, no feature/fix
- `test`: Adding/updating tests
- `chore`: Maintenance, deps, build
- `perf`: Performance improvement
- `ci`: CI/CD changes
- `revert`: Revert previous commit

**Rules:**
- Use imperative mood ("add" not "added")
- Keep subject under 72 characters
- Reference issues: `Closes #<number>` in footer

**Examples:**
- `feat(auth): add OAuth2 login`
- `fix(api): handle null response in /users endpoint`
- `docs(readme): update installation instructions`

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