import assert from "node:assert/strict";
import { test } from "node:test";

import { describe, peerOf, record } from "../extensions/herdr-activity.ts";

const cwd = "/repo";

test("each tool gets a kind and a line", () => {
  assert.deepEqual(describe("read", { path: "src/kit.js" }, cwd), { kind: "read", msg: "Reading src/kit.js" });
  assert.deepEqual(describe("edit", { path: "/repo/a.ts" }, cwd), { kind: "edit", msg: "Editing a.ts" });
  assert.deepEqual(describe("write", { path: "b.md" }, cwd), { kind: "edit", msg: "Writing b.md" });
  assert.deepEqual(describe("ls", {}, cwd), { kind: "read", msg: "Listing ." });
  assert.deepEqual(describe("bash", { command: "npm test\nrm -rf x" }, cwd), { kind: "run", msg: "Running npm test", peer: null });
  assert.deepEqual(describe("grep", { pattern: "TODO" }, cwd), { kind: "search", msg: "Searching for TODO" });
  assert.deepEqual(describe("web_search", {}, cwd), { kind: "tool", msg: "Using web_search" });
});

test("long commands are cut, bad args do not throw", () => {
  assert.equal(describe("bash", { command: "x".repeat(200) }, cwd).msg.length, "Running ".length + 80);
  assert.equal(describe("read", undefined, cwd).msg, "Reading .");
  assert.equal(describe("bash", { command: "a\tb" }, cwd).msg, "Running a b");
});

test("the record is a valid OSC 7501 child report", () => {
  const r = record({ kind: "read", msg: "Reading a.ts" });
  assert.match(r, /\x1b\]7501;state=working:id=activity:title=[A-Za-z0-9+/=]+:msg=[A-Za-z0-9+/=]+\x1b\\$/);
  assert.equal(Buffer.from(r.match(/msg=([^\x1b]+)/)![1], "base64").toString(), "Reading a.ts");
  assert.equal(record(), "\x1b]7501;state=clear:id=peer\x1b\\\x1b]7501;state=clear:id=activity\x1b\\");
});

test("hc wait and hc send name the peer", () => {
  assert.deepEqual(peerOf("hc wait t3"), { verb: "wait", target: "t3" });
  assert.deepEqual(peerOf("hc wait --timeout 600 t3 --output READY"), { verb: "wait", target: "t3" });
  assert.deepEqual(peerOf('hc send review "fix x.rs"'), { verb: "send", target: "review" });
  assert.deepEqual(peerOf("hc send --wait vps/t7 hi"), { verb: "send", target: "vps/t7" });
  assert.deepEqual(peerOf("cd x && hc wait --children"), { verb: "wait", target: "children" });
  assert.deepEqual(peerOf("cd x\nhc wait t3p --timeout 7 >/dev/null"), { verb: "wait", target: "t3p" });
  assert.equal(peerOf("hc ls --json"), null);
  assert.equal(peerOf("echo hc"), null);
  const r = record(describe("bash", { command: "hc wait t3" }, cwd));
  assert.match(r, /^\x1b\]7501;state=working:id=peer:title=d2FpdA==:msg=dDM=\x1b\\\x1b\]7501;state=working:id=activity:/);
});
