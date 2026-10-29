// pr-visual-recap Pi extension: after `gh pr create` or a push, adds a reminder to the bash
// result when the PR has no pr-visual-recap block, or when the block is older than the pushed commit.
// All logic lives in the skill's scripts/check.mjs. This file only connects it to the bash tool.

import os from "node:os"
import path from "node:path"
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent"

const CHECK = path.join(os.homedir(), ".pi/agent/skills/pr-visual-recap/scripts/check.mjs")
const TRIGGER = /\b(jj\s+git\s+push|git\s+push|gh\s+pr\s+create)\b/
const CHECK_TIMEOUT_MS = 30_000

export default function (pi: ExtensionAPI) {
  pi.on("tool_result", async (event, ctx) => {
    try {
      if (event.toolName !== "bash") return

      const command = event.input.command
      if (typeof command !== "string" || !TRIGGER.test(command)) return

      const output = event.content.map((c) => (c.type === "text" ? c.text : "")).join("\n")
      const input = JSON.stringify({ cwd: ctx.cwd, command, output })
      const result = await pi.exec("node", [CHECK, input], { cwd: ctx.cwd, timeout: CHECK_TIMEOUT_MS, signal: ctx.signal })

      const notes = result.stdout.trim()
      if (result.code !== 0 || !notes) return

      return { content: [...event.content, { type: "text", text: `\n[pr-visual-recap] ${notes}` }] }
    } catch {
      // Fail open: a reminder must never change a failed or successful command.
      return
    }
  })
}
