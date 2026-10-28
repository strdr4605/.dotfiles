// Forked from anthropics/claude-code-playground (Apache-2.0).
//
// Token Weather: a live forecast of the context window, above the prompt.
//
// The forecast uses the "smart zone" budget (default 100k tokens), not the
// model's real context window. A 1M window stays clear for a long time, but
// quality falls off far before the window ends.
//
// The budget depends on the model: Haiku degrades earliest. The order is
// manual (/token-weather N), then CLAUDE_SMART_ZONE, then the model's figure.
//
// Usage: /token-weather toggles the band. /token-weather 150000 sets the
// budget for this session.
//
// The band starts with a label: the herdr agent name (bold) and the Claude
// peer name that SendMessage uses (dim), so you can tell the two apart.

const HISTORY = 12;
const BARS = "▁▂▃▄▅▆▇█";
const DEFAULT_SMART_ZONE = 100_000;

// Keys are substrings of the model id turn.step reports (full id or alias).
const ZONE_BY_MODEL = [["haiku", 80_000]];

// Single-width text symbols, not emoji: they line up in every terminal font.
const FORECAST = [
  { upTo: 25, icon: "☀", word: "Clear", color: "yellow" },
  { upTo: 50, icon: "☁", word: "Cloudy", color: "cyan" },
  { upTo: 75, icon: "☂", word: "Showers", color: "blue" },
  { upTo: 90, icon: "☇", word: "Storm", color: "magenta" },
  { upTo: Infinity, icon: "↯", word: "Compact soon", color: "red" },
];

// Token readings, oldest first.
let readings = [];
let zone = DEFAULT_SMART_ZONE;
let override;
let enabled = true;

// Label names. Empty until a lookup finds them.
let inHerdr = false;
let herdrName = "";
let peerName = "";
let steps = 0;

export function register(on) {
  on("session.start", async ($, e, next) => {
    const result = await next(e);
    override = zoneFrom(await $.env.get("CLAUDE_SMART_ZONE"));
    await $.command.register({
      name: "token-weather",
      description: "Toggle the context forecast band, or set its budget in tokens",
      argumentHint: "[tokens]",
    });
    readings = [];
    await takeReading($);
    inHerdr = (await $.env.get("HERDR_ENV")) === "1";
    await lookUpNames($);
    return result;
  });

  // One step per model request, so the band moves after every tool round.
  on("turn.step", async function* ($, e, next) {
    const result = yield* next(e);
    if (!e.agentId) {
      zone = override ?? zoneForModel(e.model);
      await takeReading($);
      steps++;
      if (!peerName || (inHerdr && !herdrName) || steps % 10 === 0) await lookUpNames($);
    }
    return result;
  });

  // session.compact also resets, but another plugin can run first and skip
  // this mod's hook. The /compact command still reaches it.
  for (const command of ["clear", "compact"]) {
    on("command.run", { command }, async ($, e, next) => {
      const result = await next(e);
      readings = [];
      $.ui.invalidate("ui.render");
      return result;
    });
  }

  on("session.compact", async ($, e, next) => {
    const result = await next(e);
    // precompute prepares a summary without replacing the transcript.
    if (!e.agentId && e.trigger !== "precompute") {
      readings = [];
      $.ui.invalidate("ui.render");
    }
    return result;
  });

  on("ui.render", { component: "AbovePrompt" }, ($, e, next) => {
    if (!enabled || e.hasSurvey) return next(e);
    const { Box, Text } = $.ui.resolve(e);
    const parts = label(Text);
    if (readings.length > 0) parts.push(...band(Text, parts.length > 0, e.bodyColumns ?? 80));
    if (parts.length === 0) return next(e);
    return Box({ flexDirection: "row", paddingX: 1, children: parts });
  });

  on("command.run", { command: "token-weather" }, ($, e) => {
    const arg = e.args.trim();
    if (arg) {
      const parsed = Number(arg);
      if (!Number.isFinite(parsed) || parsed <= 0) return { text: `Not a token count: ${arg}` };
      zone = override = parsed;
      enabled = true;
    } else {
      enabled = !enabled;
    }
    $.ui.invalidate("ui.render");
    return { text: enabled ? `Smart zone ${short(zone)} tokens` : "Token weather off" };
  });

}

// The budget can come from the environment, so it can be empty or a typo.
function zoneFrom(raw) {
  const parsed = Number(raw);
  if (raw === undefined || raw.trim() === "" || !Number.isFinite(parsed) || parsed <= 0) return undefined;
  return parsed;
}

function zoneForModel(model) {
  const hit = ZONE_BY_MODEL.find(([key]) => model.includes(key));
  return hit ? hit[1] : DEFAULT_SMART_ZONE;
}

async function takeReading($) {
  try {
    const { context } = await $.session.usage();
    if (!context || !context.window) return;
    const tokens = context.tokens ?? 0;
    // Before the first response the figure is 0: no band until a real reading.
    if (tokens === 0) return;
    readings.push(tokens);
    if (readings.length > HISTORY) readings = readings.slice(-HISTORY);
    $.ui.invalidate("ui.render");
  } catch {
    // No reading this turn; the band keeps the last one.
  }
}

// A lookup that fails returns undefined and keeps the last name.
async function lookUpNames($) {
  const [herdr, peer] = await Promise.all([herdrNameOf($), peerNameOf($)]);
  const next = { herdr: herdr ?? herdrName, peer: peer || peerName };
  if (next.herdr === herdrName && next.peer === peerName) return;
  herdrName = next.herdr;
  peerName = next.peer;
  $.ui.invalidate("ui.render");
}

// "" when the agent has no herdr name (or the session is not in herdr).
async function herdrNameOf($) {
  try {
    const pane = await $.env.get("HERDR_PANE_ID");
    if (!inHerdr || !pane) return "";
    const { exitCode, stdout } = await $.process.run(["herdr", "agent", "get", pane], { timeoutMs: 5000 });
    if (exitCode !== 0) return undefined;
    return JSON.parse(stdout).result?.agent?.name ?? "";
  } catch {
    return undefined;
  }
}

// The mod API does not give the peer name. Each running session writes it to
// <config dir>/sessions/<pid>.json, next to its session id.
async function peerNameOf($) {
  try {
    const id = await $.session.id();
    const script = 'jq -r --arg id "$1" \'select(.sessionId == $id) | .name // empty\' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/sessions/*.json';
    const { stdout } = await $.process.run(["sh", "-c", script, "sh", id], { timeoutMs: 5000 });
    return stdout.trim().split("\n")[0];
  } catch {
    return "";
  }
}

// "<herdr-name> @<peer>". Without a herdr name: "@<peer>". Without both: nothing.
function label(Text) {
  const parts = [];
  if (herdrName) parts.push(Text({ bold: true, children: herdrName }));
  if (peerName) parts.push(Text({ dimColor: true, children: `${herdrName ? " " : ""}@${peerName}` }));
  return parts;
}

function band(Text, afterLabel, columns) {
  const now = readings[readings.length - 1];
  const percent = Math.round((now / zone) * 100);
  const f = forecastFor(percent);
  const parts = [];
  if (afterLabel) parts.push(Text({ dimColor: true, children: " │ " }));
  parts.push(Text({ color: f.color, bold: true, children: `${f.icon}  ${f.word}` }));
  if (percent >= 100) parts.push(Text({ color: "red", children: "  use /compact" }));
  parts.push(Text({ children: `  ${percent}% of smart zone` }));
  parts.push(Text({ dimColor: true, children: `  ${short(now)} / ${short(zone)}` }));
  if (columns >= 60 && readings.length >= 2) {
    parts.push(Text({ dimColor: true, children: "   last steps " }));
    parts.push(Text({ color: f.color, children: chart() }));
    parts.push(Text({ dimColor: true, children: `  ${trendWord()}` }));
  }
  return parts;
}

function forecastFor(percent) {
  return FORECAST.find((b) => percent < b.upTo) ?? FORECAST[FORECAST.length - 1];
}

// Bars scale to the busiest reading shown, so growth shows at any fill level.
function chart() {
  const top = Math.max(...readings, 1);
  return readings.map((n) => BARS[Math.min(BARS.length - 1, Math.floor((n / top) * (BARS.length - 1)))]).join("");
}

function trendWord() {
  const delta = readings[readings.length - 1] - readings[readings.length - 2];
  if (delta > 0) return `▲ +${short(delta)} last step`;
  if (delta < 0) return `▼ ${short(-delta)} last step`;
  return "steady";
}

function short(n) {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(n % 1_000_000 === 0 ? 0 : 1)}M`;
  if (n >= 1_000) return `${(n / 1_000).toFixed(n % 1_000 === 0 ? 0 : 1)}k`;
  return String(n);
}
