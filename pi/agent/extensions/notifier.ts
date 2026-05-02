/**
 * Pi Notifier Extension
 *
 * Sends desktop notifications when:
 * - Agent completes and is ready for input
 * - Tool execution fails
 *
 * Only sends when NOT focused on the pi tmux window.
 * Supports macOS, Windows, and Linux.
 */

import { execFile } from "node:child_process";
import { exec } from "node:child_process";
import os from "node:os";
import path from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const NOTIFICATION_BODY_MAX_LENGTH = 240;

type NotifierConfig = {
    enabled: boolean;
    desktop: {
        enabled: boolean;
    };
    sound: {
        enabled: boolean;
        name?: string;
    };
    events: {
        waitingForInput: boolean;
        toolError: boolean;
    };
    dedupe: {
        minIntervalMs: number;
    };
    messages: {
        waitingForInput: {
            title: string;
            body: string;
        };
        toolError: {
            title: string;
            body: string;
        };
    };
};

const DEFAULT_CONFIG: NotifierConfig = {
    enabled: true,
    desktop: {
        enabled: true,
    },
    sound: {
        enabled: true,
        name: "Glass",
    },
    events: {
        waitingForInput: true,
        toolError: true,
    },
    dedupe: {
        minIntervalMs: 2000,
    },
    messages: {
        waitingForInput: {
            title: "pi ✨",
            body: "Ready for input",
        },
        toolError: {
            title: "pi ⚠️",
            body: "Tool failed - input needed",
        },
    },
};

function escapeAppleScriptString(value: string): string {
    return value.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

function isTerminalFocused(): boolean {
    // List of common terminal app names (lowercase for comparison)
    const terminalApps = ["terminal", "iterm", "iterm2", "alacritty", "kitty", "wezterm"];
    
    try {
        const script = `tell application "System Events" to return (name of first process whose frontmost is true)`;
        const result = require("node:child_process").execSync(
            `osascript -e '${script}'`,
            { timeout: 500, encoding: "utf8" }
        ).trim().toLowerCase();
        return terminalApps.some(app => result.includes(app));
    } catch {
        return false;
    }
}

function shouldSkipNotification(): boolean {
    // Check if terminal app is frontmost
    return isTerminalFocused();
}

function getTmuxContext(): string {
    if (!process.env.TMUX) return "";
    
    try {
        const session = require("node:child_process").execSync(
            "tmux display-message -p '#S'",
            { timeout: 500, encoding: "utf8" }
        ).trim();
        
        const window = require("node:child_process").execSync(
            "tmux display-message -p '#W'",
            { timeout: 500, encoding: "utf8" }
        ).trim();
        
        const fullPath = require("node:child_process").execSync(
            "tmux display-message -p '#{pane_current_path}'",
            { timeout: 500, encoding: "utf8" }
        ).trim();
        
        // Abbreviate path: only show last 2 parts
        const pathParts = fullPath.replace(/^\/~/, "").split("/").filter(p => p.length > 0);
        const shortPath = pathParts.length > 2
            ? pathParts.slice(-2).join("/")
            : fullPath.replace(/^\/Users\/[^/]+\//, "~");
        
        return `${session}:${window} • ${shortPath}`;
    } catch {
        return "";
    }
}

function execFileAsync(command: string, args: string[]): Promise<void> {
    return new Promise<void>((resolve, reject) => {
        execFile(command, args, (error) => {
            if (error) reject(error);
            else resolve();
        });
    });
}

async function notifyMacOS(
    title: string,
    body: string,
    soundEnabled: boolean,
    soundName?: string,
): Promise<void> {
    const escapedTitle = escapeAppleScriptString(title);
    const escapedBody = escapeAppleScriptString(body);
    let script = `display notification "${escapedBody}" with title "${escapedTitle}"`;
    if (soundEnabled && soundName) {
        script += ` sound name "${escapeAppleScriptString(soundName)}"`;
    }
    await execFileAsync("osascript", ["-e", script]);
}

async function notifyWindows(
    title: string,
    body: string,
): Promise<void> {
    const escapedTitle = title.replace(/"/g, '""');
    const escapedBody = body.replace(/"/g, '""');

    const script = [
        `[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null`,
        `$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)`,
        `$textNodes = $template.GetElementsByTagName('text')`,
        `$textNodes[0].AppendChild($template.CreateTextNode('${escapedTitle}')) > $null`,
        `$textNodes[1].AppendChild($template.CreateTextNode('${escapedBody}')) > $null`,
        `$toast = [Windows.UI.Notifications.ToastNotification]::new($template)`,
        `[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('pi').Show($toast)`,
    ].join("; ");

    await new Promise<void>((resolve, reject) => {
        execFile("powershell.exe", ["-NoProfile", "-Command", script], (error) => {
            if (error) reject(error);
            else resolve();
        });
    });
}

async function notifyLinux(
    title: string,
    body: string,
): Promise<void> {
    await execFileAsync("notify-send", [
        "--app-name=pi",
        "--expire-time=8000",
        "--urgency=normal",
        "--",
        title,
        body,
    ]);
}

export default function notifierExtension(pi: ExtensionAPI) {
    const lastSentAt = new Map<string, number>();

    function shouldNotify(key: string): boolean {
        const now = Date.now();
        const previous = lastSentAt.get(key) ?? 0;
        if (now - previous < DEFAULT_CONFIG.dedupe.minIntervalMs) return false;
        lastSentAt.set(key, now);
        return true;
    }

    async function notifyDesktop(title: string, body: string): Promise<boolean> {
        if (!DEFAULT_CONFIG.desktop.enabled) return false;
        if (!shouldNotify(title + body)) return false;

        try {
            if (process.platform === "darwin") {
                await notifyMacOS(
                    title,
                    body,
                    DEFAULT_CONFIG.sound.enabled,
                    DEFAULT_CONFIG.sound.name,
                );
            } else if (process.platform === "win32") {
                await notifyWindows(title, body);
            } else if (process.platform === "linux") {
                await notifyLinux(title, body);
            }
            return true;
        } catch (error) {
            console.error(`[pi-notifier] Failed to send notification: ${error}`);
            return false;
        }
    }

    // Handle agent_end - defer notification to avoid interfering with TUI state
    pi.on("agent_end", () => {
        if (!DEFAULT_CONFIG.events.waitingForInput) return;
        
        setImmediate(() => {
            try {
                if (shouldSkipNotification()) return;
                const context = getTmuxContext();
                const body = context 
                    ? `Ready • ${context}` 
                    : DEFAULT_CONFIG.messages.waitingForInput.body;
                notifyDesktop(
                    DEFAULT_CONFIG.messages.waitingForInput.title,
                    body,
                ).catch(() => {});
            } catch {
                // Ignore errors in deferred notification
            }
        });
    });

    // Handle tool errors
    pi.on("tool_execution_end", async (event) => {
        if (!DEFAULT_CONFIG.events.toolError) return;
        if (event.isError) {
            setImmediate(() => {
                try {
                    if (shouldSkipNotification()) return;
                    const context = getTmuxContext();
                    const body = context 
                        ? `${event.toolName} failed • ${context}` 
                        : `${event.toolName} failed`;
                    notifyDesktop(
                        DEFAULT_CONFIG.messages.toolError.title,
                        body,
                    ).catch(() => {});
                } catch {
                    // Ignore errors in deferred notification
                }
            });
        }
    });

    // Test command
    pi.registerCommand("pi-notifier-test", {
        description: "Send a test notification",
        handler: async (_args, ctx) => {
            const sent = await notifyDesktop("pi test", "Test notification");
            ctx.ui.notify(
                sent ? "Test notification sent" : "Test notification skipped (dedupe)",
                sent ? "info" : "warning",
            );
        },
    });
}