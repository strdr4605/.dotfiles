import assert from "node:assert/strict";
import { test } from "node:test";

import { describe, record } from "../extensions/herdr-activity.ts";

const cwd = "/repo";

test("each tool gets a kind and a line", () => {
  assert.deepEqual(describe("read", { path: "src/kit.js" }, cwd), { kind: "read", msg: "Reading src/kit.js" });
  assert.deepEqual(describe("edit", { path: "/repo/a.ts" }, cwd), { kind: "edit", msg: "Editing a.ts" });
  assert.deepEqual(describe("write", { path: "b.md" }, cwd), { kind: "edit", msg: "Writing b.md" });
  assert.deepEqual(describe("ls", {}, cwd), { kind: "read", msg: "Listing ." });
  assert.deepEqual(describe("bash", { command: "npm test\nrm -rf x" }, cwd), { kind: "run", msg: "Running npm test" });
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
  assert.match(r, /^\x1b\]7501;state=working:id=activity:title=[A-Za-z0-9+/=]+:msg=[A-Za-z0-9+/=]+\x1b\\$/);
  assert.equal(Buffer.from(r.match(/msg=([^\x1b]+)/)![1], "base64").toString(), "Reading a.ts");
  assert.equal(record(), "\x1b]7501;state=clear:id=activity\x1b\\");
});
