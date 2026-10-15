# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (cuts up to 90% of bash output)

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk bypass <cmd>      # Execute raw command without filtering (for debugging; `rtk proxy` is a deprecated alias)
rtk pipeline explain  # Show which compression rules fire for an agent/tool/format
rtk pipeline validate # Validate custom pipeline files
```

## Installation Verification

```bash
rtk --version         # Should show: rtk 1.x.y (1.0+ required: bypass, pipelines)
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

## Hook-Based Usage

All other commands are automatically rewritten by the Claude Code hook.
Example: `git status` → `rtk git status` (transparent, 0 tokens overhead)

Since 1.0 the hook also has a gate: a pipeline rule can block or route a command. If a command is refused, run `rtk pipeline explain` to see the rule.

`--ultra-compact` was removed in 1.0; do not use it.

Refer to CLAUDE.md for full command reference.
