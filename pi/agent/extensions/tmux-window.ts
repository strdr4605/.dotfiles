/**
 * Tmux Window Manager Extension
 *
 * Manages tmux window naming for pi sessions:
 * - Session start: rename to "pi-<project>" or "pi"
 * - Session end: restore to "zsh"
 * - Every 10 turns: check if context changed, update name if meaningful progress
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  let turnCount = 0;
  let lastContextSnapshot = "";
  let windowRenamed = false;

  // Rename tmux window helper
  async function renameWindow(name: string): Promise<void> {
    try {
      await pi.exec("tmux", ["rename-window", name]);
      windowRenamed = true;
    } catch (e) {
      // tmux not available or error - that's fine
    }
  }

  // Restore window to default
  async function restoreWindow(): Promise<void> {
    if (windowRenamed) {
      try {
        await pi.exec("tmux", ["rename-window", "zsh"]);
      } catch (e) {
        // ignore
      }
      windowRenamed = false;
    }
  }

  // Get short project name from cwd
  function getProjectName(cwd: string): string {
    // Get the last meaningful segment
    const parts = cwd.split("/").filter(Boolean);
    if (parts.length === 0) return "home";
    
    const last = parts[parts.length - 1];
    // Shorten if too long
    if (last.length > 12) {
      return last.slice(0, 10) + "…";
    }
    return last;
  }

  // Create a snapshot of current context (files being worked on)
  function getContextSnapshot(): string {
    const entries = ctx.sessionManager.getBranch();
    const files = new Set<string>();
    
    for (const entry of entries) {
      if (entry.type === "message" && entry.message?.role === "toolResult") {
        const content = entry.message.content;
        if (Array.isArray(content)) {
          for (const block of content) {
            if (block.type === "text") {
              // Extract file paths from tool results
              const matches = block.text.match(/\/[\w\-\.]+\/[\w\-\.]+/g);
              if (matches) {
                matches.forEach((m) => {
                  // Normalize to just the project-relative path
                  const normalized = m.split("/").slice(-3).join("/");
                  files.add(normalized);
                });
              }
            }
          }
        }
      }
    }
    
    return Array.from(files).sort().join("|");
  }

  // Reference to context for later
  let ctx: import("@mariozechner/pi-coding-agent").ExtensionContext | null = null;

  // Session start - rename window
  pi.on("session_start", async (event, extCtx) => {
    ctx = extCtx;
    turnCount = 0;
    lastContextSnapshot = "";
    
    const projectName = getProjectName(extCtx.cwd);
    await renameWindow(`pi-${projectName}`);
  });

  // Session shutdown - restore window
  pi.on("session_shutdown", async () => {
    await restoreWindow();
  });

  // Track turns and update name if context changed significantly
  pi.on("turn_end", async (event, extCtx) => {
    turnCount++;
    ctx = extCtx;
    
    // Every 10 turns, check for meaningful context change
    if (turnCount % 10 === 0) {
      const currentSnapshot = getContextSnapshot();
      
      // If context changed (new files or significant changes), update window name
      if (currentSnapshot !== lastContextSnapshot && lastContextSnapshot !== "") {
        const newFiles = currentSnapshot.split("|").filter(
          (f) => !lastContextSnapshot.split("|").includes(f)
        );
        
        if (newFiles.length > 0) {
          // Found new files - summarize the progress
          const projectName = getProjectName(extCtx.cwd);
          const progress = `pi-${projectName}*`; // Mark with * to indicate progress
          await renameWindow(progress);
          
          // After a moment, simplify back (unless another turn happens)
          setTimeout(async () => {
            await renameWindow(`pi-${projectName}`);
          }, 2000);
        }
      }
      
      lastContextSnapshot = currentSnapshot;
    }
  });

  // On agent end, ensure window is restored
  pi.on("agent_end", async () => {
    // Nothing to do here, session_shutdown handles it
  });
}
