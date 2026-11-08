// Cmd+U: the links on the focused terminal's screen, opened in the browser.
// Like Alacritty's hints: list what is on screen, pick a number, open it.
import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { focused, hc, exec, closeOverlay, props, theme, notify } from "herdr";

const URL_RE = /(?:https?|ftps?|file|mailto|gemini|magnet|git|ssh|ipfs|ipns|news|gopher):[^\s<>"'`]+/g;
const VISIBLE = 8;

export default class Links extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.focusing = false;
    this.links = [];
    this.sel = 0;
    this.loading = true;
    this.focus();
    cx.timer.after(300, () => this.focus());
  }

  // The view is reused between openings: take the keyboard again every draw.
  focus() {
    if (this.focusing || this.handle.is_focused()) return;
    this.focusing = true;
    this.handle.focus();
    this.focusing = false;
  }

  async load(cx) {
    const f = focused();
    const t = f && f.terminal;
    if (!t) {
      this.links = [];
      this.loading = false;
      cx.notify();
      return;
    }
    const res = await hc(["read", t]);
    const found = (res.stdout || "").match(URL_RE) || [];
    const seen = [];
    for (const raw of found) {
      const url = raw.replace(/[.,;:!?)\]}>'"]+$/, "");
      if (url && !seen.includes(url)) seen.push(url);
    }
    this.links = seen;
    this.sel = 0;
    this.loading = false;
    cx.notify();
  }

  open(url) {
    exec("open", [url]);
    notify({ title: "Link opened", body: url, level: "info", timeout: 3000 });
    closeOverlay(props().overlay);
  }

  move(step) {
    if (!this.links.length) return;
    const n = this.links.length;
    this.sel = ((this.sel + step) % n + n) % n;
  }

  key(e, cx) {
    if (e.key === "escape") {
      closeOverlay(props().overlay);
      cx.stop_propagation();
      return;
    }
    if (e.modifiers.control || e.modifiers.platform || e.modifiers.alt) return;
    if (e.key === "down") {
      this.move(1);
      cx.stop_propagation();
      return;
    }
    if (e.key === "up") {
      this.move(-1);
      cx.stop_propagation();
      return;
    }
    if (e.key === "j") {
      this.move(1);
      cx.stop_propagation();
      return;
    }
    if (e.key === "k") {
      this.move(-1);
      cx.stop_propagation();
      return;
    }
    if (e.key === "enter") {
      if (this.links[this.sel]) this.open(this.links[this.sel]);
      cx.stop_propagation();
      return;
    }
    if (/^[1-9]$/.test(e.key)) {
      const i = Number(e.key) - 1;
      if (this.links[i]) this.open(this.links[i]);
      cx.stop_propagation();
    }
  }

  render(cx) {
    const o = props();
    // A new overlay means a new screen to read.
    if (o && o.overlay && o.overlay !== this.overlay) {
      this.overlay = o.overlay;
      this.links = [];
      this.sel = 0;
      this.loading = true;
      cx.timer.after(0, (cx) => this.load(cx));
    }
    if (!this.handle.is_focused()) {
      cx.timer.after(50, () => this.focus());
    }
    const t = theme();
    const total = this.links.length;
    // Keep the selection inside the shown rows.
    let start = 0;
    if (total > VISIBLE) {
      start = Math.max(0, Math.min(this.sel - Math.floor(VISIBLE / 2), total - VISIBLE));
    }
    const head = this.loading
      ? "reading screen..."
      : total
        ? `links on screen (${total})`
        : "no link on screen";
    const pick = t.selection || t.raised;
    return v_flex()
      .id("links")
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .p(10)
      .gap(8)
      .bg(t.popover)
      .text_color(t.foreground)
      .child(div().text_size(12).font_semibold().text_color(t.muted).child(head))
      .children(
        this.links.slice(start, start + VISIBLE).map((u, i) => {
          const idx = start + i;
          const on = idx === this.sel;
          return h_flex().gap(8).items_center()
            .on_click(() => this.open(u))
            .child(
              div().rounded(4).px(5).text_size(11).bg(on ? pick : t.raised)
                .child(on ? "› " + (idx + 1) : String(idx + 1))
            )
            .child(div().text_size(11.5).child(u.length > 90 ? u.slice(0, 90) + "…" : u));
        })
      )
      .child(
        div().text_size(10.5).text_color(t.muted)
          .child(total > VISIBLE ? "↑↓ or j/k to move, enter to open, esc to cancel" : "1-9 to open, enter to open, esc to cancel")
      );
  }
}
