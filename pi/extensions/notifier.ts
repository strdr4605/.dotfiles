/**
 * Pi Notifier Extension
 *
 * Sends desktop notifications for key agent events:
 * - Tool permission requests (when user needs to approve dangerous operations)
 * - Agent completion (when ready for next input)
 * - Errors
 *
 * Supports multiple terminal protocols:
 * - OSC 777: Ghostty, iTerm2, WezTerm, rxvt-unicode
 * - OSC 99: Kitty
 * - Windows toast: Windows Terminal (WSL)
 * - macOS: osascript, node-notifier
 * - Linux: notify-send
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

interface NotifyOptions {
  title: string;
  message: string;
  sound?: boolean;
}

const DEBOUNCE_MS = 1000;
const lastNotificationTime: Record<string, number> = {};

function shouldNotify(key: string): boolean {
  const now = Date.now();
  if (lastNotificationTime[key] && now - lastNotificationTime[key] < DEBOUNCE_MS) {
    return false;
  }
  lastNotificationTime[key] = now;
  return true;
}

function sanitizeField(value: string): string {
  return value.replace(/[;\x07\x1b\n\r]/g, "");
}

function notifyOSC777(title: string, message: string): void {
  process.stdout.write(`\x1b]777;notify;${title};${message}\x07`);
}

function notifyOSC99(title: string, message: string): void {
  process.stdout.write(`\x1b]99;i=1:d=0;${title}\x1b\\`);
  process.stdout.write(`\x1b]99;i=1:p=body;${message}\x1b\\`);
}

function notifyGhostty(title: string, message: string): void {
  const escapedTitle = sanitizeField(title);
  const escapedMessage = sanitizeField(message);
  let payload = `\x1b]9;${escapedTitle}: ${escapedMessage}\x07`;

  if (process.env.TMUX) {
    payload = `\x1bPtmux;\x1b${payload}\x1b\\`;
  }

  process.stdout.write(payload);
}

function notifyDarwinOsascript(title: string, message: string, sound?: boolean): void {
  const { exec } = require("child_process");
  const escapedMessage = message.replace(/"/g, '\\"');
  const escapedTitle = title.replace(/"/g, '\\"');
  const soundFlag = sound ? "" : "in volume 0 ";

  exec(
    `osascript -e 'display notification "${escapedMessage}" with title "${escapedTitle}" ${soundFlag}sound playing alert sound'`,
    () => {}
  );
}

function notifyDarwinTerminal(title: string, message: string): void {
  // Terminal.app doesn't support notifications directly
  // Fall back to osascript
  notifyDarwinOsascript(title, message, true);
}

function notifyWindows(title: string, message: string): void {
  const { execFile } = require("child_process");

  const escapedTitle = title.replace(/"/g, '""');
  const escapedMessage = message.replace(/"/g, '""');

  const script = [
    `[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null`,
    `$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)`,
    `$textNodes = $template.GetElementsByTagName('text')`,
    `$textNodes[0].AppendChild($template.CreateTextNode('${escapedTitle}')) > $null`,
    `$textNodes[1].AppendChild($template.CreateTextNode('${escapedMessage}')) > $null`,
    `$toast = [Windows.UI.Notifications.ToastNotification]::new($template)`,
    `[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('pi').Show($toast)`,
  ].join("; ");

  execFile("powershell.exe", ["-NoProfile", "-Command", script]);
}

function notifyLinux(title: string, message: string): void {
  const { execFile } = require("child_process");

  const args = [
    "--app-name=pi",
    "--expire-time=5000",
    "--urgency=normal",
    "--",
    title,
    message,
  ];

  execFile("notify-send", args);
}

function notify(options: NotifyOptions): void {
  const { title, message } = options;

  if (!shouldNotify(message)) {
    return;
  }

  // Terminal-specific protocols
  if (process.env.WT_SESSION) {
    notifyWindows(title, message);
  } else if (process.env.GHOSTTY_RESOURCES_DIR) {
    notifyGhostty(title, message);
  } else if (process.env.KITTY_WINDOW_ID) {
    notifyOSC99(title, message);
  } else if (process.env.TERM_PROGRAM === "iTerm.app" || process.env.TERM === "xterm-256color") {
    notifyOSC777(title, message);
  } else if (process.platform === "darwin") {
    // Check if Terminal.app (prefer osascript for all macOS)
    notifyDarwinOsascript(title, message, true);
  } else if (process.platform === "win32") {
    notifyWindows(title, message);
  } else if (process.platform === "linux") {
    notifyLinux(title, message);
  }
}

export default function (pi: ExtensionAPI) {
  // Agent completed - ready for input
  pi.on("agent_end", async () => {
    notify({
      title: "pi",
      message: "Ready for input",
    });
  });

  // Tool execution error
  pi.on("tool_execution_end", async (event, _ctx) => {
    if (event.isError) {
      notify({
        title: "pi",
        message: `Error: ${event.toolName} failed`,
      });
    }
  });

  // Model change notification
  pi.on("model_select", async (event, _ctx) => {
    const model = event.model;
    const modelName = model.id.length > 20 ? model.id.slice(0, 17) + "..." : model.id;
    notify({
      title: "pi",
      message: `Model: ${modelName}`,
    });
  });

  // Session started
  pi.on("session_start", async (event, _ctx) => {
    if (event.reason === "startup") {
      notify({
        title: "pi",
        message: "Session started",
      });
    }
  });
}
