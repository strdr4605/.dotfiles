import assert from "node:assert/strict";
import { test } from "node:test";

import { chart, forecastFor, formatLine, short, withLabel, zoneFromEnv } from "../extensions/token-weather.ts";

test("band edges", () => {
	assert.equal(forecastFor(0).word, "Clear");
	assert.equal(forecastFor(24).word, "Clear");
	assert.equal(forecastFor(25).word, "Cloudy");
	assert.equal(forecastFor(50).word, "Showers");
	assert.equal(forecastFor(75).word, "Storm");
	assert.equal(forecastFor(90).word, "Compact soon");
	assert.equal(forecastFor(100).word, "Compact soon");
});

test("budget from the environment", () => {
	assert.equal(zoneFromEnv(undefined), 100_000);
	assert.equal(zoneFromEnv(""), 100_000);
	assert.equal(zoneFromEnv("abc"), 100_000);
	assert.equal(zoneFromEnv("0"), 100_000);
	assert.equal(zoneFromEnv("-5"), 100_000);
	assert.equal(zoneFromEnv("150000"), 150_000);
});

test("short token counts", () => {
	assert.equal(short(999), "999");
	assert.equal(short(1_500), "1.5k");
	assert.equal(short(100_000), "100k");
	assert.equal(short(1_500_000), "1.5M");
});

test("sparkline scales to the largest reading", () => {
	assert.equal(chart([]), "");
	assert.equal(chart([1_000, 2_000, 3_000]), "▃▅█");
});

test("line with no reading", () => {
	assert.equal(formatLine([], 100_000), "☀ Clear 0% of smart zone 0 / 100k");
});

test("line with readings", () => {
	const line = formatLine([50_000, 60_000], 100_000);
	assert.match(line, /☂ Showers/);
	assert.match(line, /60% of smart zone/);
	assert.match(line, /60k \/ 100k/);
	assert.match(line, /▲ \+10k last turn/);
});

test("a bad budget never prints NaN", () => {
	assert.doesNotMatch(formatLine([60_000], 0), /NaN/);
});

test("the full zone asks for /compact or /handoff", () => {
	const line = formatLine([100_000], 100_000);
	assert.match(line, /use \/compact or \/handoff/);
	assert.match(formatLine([120_000], 100_000), /use \/compact or \/handoff/);
	assert.doesNotMatch(formatLine([99_000], 100_000), /handoff/);
	// The hint must stay near the front, because the footer cuts the tail.
	assert.ok(line.indexOf("handoff") < line.indexOf("% of smart zone"));
});

test("herdr label", () => {
	assert.equal(withLabel("", "☀ Clear"), "☀ Clear");
	assert.equal(withLabel("planner", "☀ Clear"), "│ planner │ ☀ Clear");
	assert.equal(withLabel("planner", "☀ Clear", (s) => `*${s}*`), "│ *planner* │ ☀ Clear");
});
