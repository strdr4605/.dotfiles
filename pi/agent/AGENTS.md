# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy. It cuts up to 90% of bash output.

## Automatic rewriting

The RTK extension rewrites every bash command before it runs. Example: `git status` runs as `rtk git status`.

The extension fails open. If `rtk` is missing or too old, the command runs unchanged. The status bar then shows `RTK disabled`.

## Meta commands (use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze pi history for missed opportunities
rtk bypass <cmd>      # Execute raw command without filtering
rtk pipeline explain  # Show which compression rules fire
rtk pipeline validate # Validate custom pipeline files
```

## Verification

```bash
rtk --version   # Must show rtk 1.x.y
which rtk       # Verify correct binary
```

Warning: `rtk gain` fails when the Rust Type Kit (`reachingforthejack/rtk`) is installed instead.

## Browser work with surf

When Pi drives the browser with `surf`, keep the user oriented:

- Session name: `pi-surf`.
- Move the surf tab into the window the user watches: `surf tab.move <tabId> --to-window <focusedWindowId>`. Get the window id from `surf window.list --tabs` (the window marked `[focused]`).
- Group the tab as `pi:surf ⏳` while the work runs, and `pi:surf ✅` when the work is done.
- Set the tab title to `⏳ pi:surf` while the work runs, and `✅ pi:surf` when the work is done. Navigation resets the title, so set it again after each `surf go`.
- Leave the tab open for the user, or close it with `surf session.close "$SURF_SESSION"`.

# Notes

- `--ultra-compact` was removed in 1.0. Do not use it.
- Run `rtk --help` for the full command reference.
