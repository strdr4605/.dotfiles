// Ctrl+A prefix, like tmux. Press ctrl+a, then a key:
//   v split right   h split down   c new tab   x close pane
//   d detach (quit the window; terminals keep running)
//   i recap report  u recap plan   Esc cancel
import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { run, props, closeOverlay, theme, home } from "herdr";

const RECAP = home() + "/.local/bin/recap";

const ACTIONS = {
  v: () => run("pane.split", { direction: "right" }),
  h: () => run("pane.split", { direction: "down" }),
  c: () => run("tab.new"),
  x: () => run("pane.close"),
  d: () => run("app.quit"),
  i: () => run("tab.new", { name: "recap", argv: [RECAP] }),
  u: () => run("tab.new", { name: "recap plan", argv: [RECAP, "plan"] }),
};

const HINTS = [
  ["v", "split right"], ["h", "split down"], ["c", "new tab"], ["x", "close pane"],
  ["d", "detach"], ["i", "recap"], ["u", "recap plan"], ["esc", "cancel"],
];

export default class Prefix extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.focusing = false;
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

  key(e, cx) {
    if (e.key === "escape") {
      closeOverlay(props().overlay);
      cx.stop_propagation();
      return;
    }
    // ctrl+a again: close the prefix and let the key through.
    if (e.key === "a" && e.modifiers.control) {
      closeOverlay(props().overlay);
      cx.stop_propagation();
      return;
    }
    if (e.modifiers.control || e.modifiers.platform || e.modifiers.alt) return;
    const action = ACTIONS[e.key];
    if (!action) {
      closeOverlay(props().overlay);
      cx.stop_propagation();
      return;
    }
    cx.stop_propagation();
    action();
    closeOverlay(props().overlay);
  }

  render(cx) {
    if (!this.handle.is_focused()) {
      cx.timer.after(50, () => this.focus());
    }
    const t = theme();
    return v_flex()
      .id("prefix")
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .p(10)
      .gap(8)
      .bg(t.popover)
      .text_color(t.foreground)
      .child(
        h_flex()
          .gap(12)
          .child(div().text_size(12.5).font_semibold().text_color(t.muted).child("ctrl+a"))
          .child(
            h_flex().gap(10).flex_1().children(
              HINTS.map(([k, label]) =>
                h_flex().gap(4).items_center()
                  .child(div().rounded(4).px(5).text_size(11).text_color(t.foreground).bg(t.raised).child(k))
                  .child(div().text_size(11.5).text_color(t.muted).child(label))
              )
            )
          )
      );
  }
}
