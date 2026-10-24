/**
 * Token Weather
 *
 * A live forecast of the context window, shown on the footer status line,
 * next to the ponytail status.
 *
 * The forecast uses the "smart zone" budget that people report for coding
 * agents (about 80k to 150k tokens), not the model's real context window.
 * A model with a 1M window stays in the clear for a long time. That is true,
 * but it hides the point: quality falls off far before the window ends.
 *
 * Usage: /token-weather toggles the band. /token-weather 150000 sets the
 * budget. The budget also comes from PI_SMART_ZONE.
 */

import type { ExtensionAPI, ExtensionContext, ThemeColor } from "@earendil-works/pi-coding-agent";

const HISTORY = 12;
const BARS = "▁▂▃▄▅▆▇█";
const DEFAULT_SMART_ZONE = 100_000;

// Single-width text symbols, not emoji: they line up in every terminal font.
export const FORECAST = [
	{ upTo: 25, icon: "☀", word: "Clear", color: "success" },
	{ upTo: 50, icon: "☁", word: "Cloudy", color: "muted" },
	{ upTo: 75, icon: "☂", word: "Showers", color: "accent" },
	{ upTo: 90, icon: "☇", word: "Storm", color: "warning" },
	{ upTo: Infinity, icon: "↯", word: "Compact soon", color: "error" },
] as const;

// The budget can come from the environment, so it can be empty or a typo.
export function zoneFromEnv(raw: string | undefined): number {
	const parsed = Number(raw);
	if (raw === undefined || raw.trim() === "" || !Number.isFinite(parsed) || parsed <= 0) {
		return DEFAULT_SMART_ZONE;
	}
	return parsed;
}

export function forecastFor(percent: number) {
	return FORECAST.find((band) => percent < band.upTo) ?? FORECAST[FORECAST.length - 1];
}

// Bars scale to the busiest reading shown, so growth shows at any fill level.
export function chart(tokens: number[]): string {
	if (tokens.length === 0) return "";
	const top = Math.max(...tokens, 1);
	return tokens
		.map((n) => BARS[Math.min(BARS.length - 1, Math.floor((n / top) * (BARS.length - 1)))])
		.join("");
}

export function short(n: number): string {
	if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(n % 1_000_000 === 0 ? 0 : 1)}M`;
	if (n >= 1_000) return `${(n / 1_000).toFixed(n % 1_000 === 0 ? 0 : 1)}k`;
	return String(n);
}

export function formatLine(tokens: number[], zone: number, fg?: (color: ThemeColor, text: string) => string): string {
	const now = tokens[tokens.length - 1] ?? 0;
	const percent = zone > 0 ? Math.round((now / zone) * 100) : 0;
	const band = forecastFor(percent);
	const paint = (color: ThemeColor, text: string) => (fg ? fg(color, text) : text);
	const parts = [paint(band.color, `${band.icon} ${band.word}`)];

	// The footer cuts the end of the line on a narrow terminal, so the hint
	// sits next to the band, where it stays visible.
	if (percent >= 100) {
		parts.push("use /compact or /handoff");
	}

	parts.push(`${percent}% of smart zone`, `${short(now)} / ${short(zone)}`);

	if (tokens.length >= 2) {
		const delta = now - tokens[tokens.length - 2];
		parts.push(`last turns ${chart(tokens)}`);
		parts.push(delta > 0 ? `▲ +${short(delta)} last turn` : delta < 0 ? `▼ ${short(-delta)} last turn` : "steady");
	}

	return parts.join(" ");
}

export default function tokenWeatherExtension(pi: ExtensionAPI) {
	const readings: number[] = [];
	let zone = zoneFromEnv(process.env.PI_SMART_ZONE);
	let enabled = true;

	function render(ctx: ExtensionContext) {
		if (ctx.mode !== "tui") return;
		if (!enabled) {
			ctx.ui.setStatus("token-weather", undefined);
			return;
		}
		// The footer puts extension statuses on one line, sorted by key. The key
		// "token-weather" sorts after "ponytail", so the band sits next to it.
		const fg = ctx.ui.theme?.fg?.bind(ctx.ui.theme);
		ctx.ui.setStatus("token-weather", formatLine(readings, zone, fg));
	}

	function takeReading(ctx: ExtensionContext) {
		const usage = ctx.getContextUsage();
		if (!usage || usage.tokens === null || usage.tokens === undefined) return;
		readings.push(usage.tokens);
		if (readings.length > HISTORY) readings.shift();
	}

	pi.on("session_start", (_event, ctx) => {
		readings.length = 0;
		takeReading(ctx);
		render(ctx);
	});

	pi.on("turn_end", (_event, ctx) => {
		takeReading(ctx);
		render(ctx);
	});

	pi.on("session_compact", (_event, ctx) => {
		readings.length = 0;
		render(ctx);
	});

	pi.registerCommand("token-weather", {
		description: "Toggle the context forecast band, or set its budget in tokens",
		handler: async (args, ctx) => {
			const arg = args.trim();

			if (arg) {
				const parsed = Number(arg);
				if (!Number.isFinite(parsed) || parsed <= 0) {
					ctx.ui.notify(`Not a token count: ${arg}`, "warning");
					return;
				}
				zone = parsed;
				enabled = true;
			} else {
				enabled = !enabled;
			}

			render(ctx);
			ctx.ui.notify(enabled ? `Smart zone ${short(zone)} tokens` : "Token weather off", "info");
		},
	});
}
