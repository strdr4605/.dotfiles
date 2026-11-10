/**
 * Herdr activity: tells Herdr which tool pi runs now.
 *
 * Pi reports its own status (working, blocked, done) in the OSC 7501 root
 * record. This extension adds the child record "activity" beside it:
 *   title  the kind: read, edit, run, search or tool
 *   msg    one line for people, e.g. "Reading src/kit.js"
 * While bash runs `hc wait <t>` or `hc send <t>`, the child record "peer"
 * tells who this agent talks to:
 *   title  the verb: wait or send
 *   msg    the target: an address, a name, or "children" for `hc wait --children`
 * A child record does not change the root status, so it cannot hide "blocked".
 * The records are removed when no tool runs.
 *
 * Spec: https://www.superlogical.com/rex/docs/build/program-status
 */

import path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const ID = "activity";
const MAX = 80;

export type Peer = { verb: "wait" | "send"; target: string };
export type Activity = { kind: "read" | "edit" | "run" | "search" | "tool"; msg: string; peer?: Peer | null };

export default function (pi: ExtensionAPI) {
  // shortcut: only in Herdr core terminals, add the OSC 7501 support query if another terminal needs it.
  if (!process.env.HC_TERMINAL_ID || !process.stdout.isTTY) return;

  const running = new Map<string, Activity>();
  let cwd = process.cwd();

  const report = () => process.stdout.write(record([...running.values()].at(-1)));

  pi.on("session_start", (_event, ctx) => {
    cwd = ctx.cwd;
  });

  pi.on("tool_execution_start", (event) => {
    running.set(event.toolCallId, describe(event.toolName, event.args, cwd));
    report();
  });

  pi.on("tool_execution_end", (event) => {
    running.delete(event.toolCallId);
    report();
  });

  // An aborted run can skip tool_execution_end.
  pi.on("agent_settled", () => {
    running.clear();
    report();
  });

  pi.on("session_shutdown", () => {
    running.clear();
    report();
  });
}

// ---- the report

export function describe(tool: string, args: any, cwd: string): Activity {
  const where = (p?: string) => short(p ? path.relative(cwd, path.resolve(cwd, p)) || "." : ".");

  switch (tool) {
    case "read":
      return { kind: "read", msg: `Reading ${where(args?.path)}` };
    case "ls":
      return { kind: "read", msg: `Listing ${where(args?.path)}` };
    case "edit":
      return { kind: "edit", msg: `Editing ${where(args?.path)}` };
    case "write":
      return { kind: "edit", msg: `Writing ${where(args?.path)}` };
    case "bash":
    case "powershell":
      return { kind: "run", msg: `Running ${short(args?.command)}`, peer: peerOf(args?.command) };
    case "grep":
      return { kind: "search", msg: `Searching for ${short(args?.pattern)}` };
    case "find":
      return { kind: "search", msg: `Finding ${short(args?.pattern)}` };
    default:
      return { kind: "tool", msg: `Using ${short(tool)}` };
  }
}

/** The OSC 7501 reports for the peer and activity records. No activity clears both. */
export function record(activity?: Activity): string {
  const peer = activity?.peer;
  return osc("peer", peer && { title: peer.verb, msg: peer.target }) + osc(ID, activity && { title: activity.kind, msg: activity.msg });
}

function osc(id: string, rec?: { title: string; msg: string } | null): string {
  if (!rec) return `\x1b]7501;state=clear:id=${id}\x1b\\`;
  return `\x1b]7501;state=working:id=${id}:title=${b64(rec.title)}:msg=${b64(rec.msg)}\x1b\\`;
}

// The agent a command talks to: `hc wait t3`, `hc send review "..."`, `hc wait --children`.
export function peerOf(command: unknown): Peer | null {
  const m = /\bhc\s+(wait|send)\s+(.*)/.exec(String(command ?? ""));
  if (!m) return null;
  const verb = m[1] as Peer["verb"];
  const words = m[2].split(/\s+/);
  for (let i = 0; i < words.length; i++) {
    const w = words[i];
    if (w === "--children") return { verb, target: "children" };
    if (w === "--output" || w === "--timeout") i++;
    else if (w && !w.startsWith("-")) return { verb, target: w.replace(/^["']|["';&|)]+$/g, "") };
  }
  return null;
}

// One line, no control characters, at most MAX characters.
function short(text: unknown): string {
  const line = String(text ?? "").split(/\r?\n/, 1)[0].replace(/\p{Cc}/gu, " ").trim();
  return line.length > MAX ? `${line.slice(0, MAX - 1)}…` : line;
}

const b64 = (text: string) => Buffer.from(text, "utf8").toString("base64");
