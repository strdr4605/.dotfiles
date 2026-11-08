// Reports the live folder of every pane to /tmp/planck-cwd.json, then closes.
// The app knows a pane's real folder; the shell (hc ls) only knows where it started.
import { View, div } from "gpui-kit";
import { panes, focused, exec, closeOverlay, props } from "herdr";

const FILE = "/tmp/planck-cwd.json";

export default class Cwd extends View {
  render(cx) {
    const f = focused();
    const list = panes().map((p) => ({
      pane: p.pane,
      terminal: p.terminal,
      cwd: p.cwd,
      status: p.status,
      app: p.app,
      focused: p.focused,
      title: p.title,
    }));
    const body = JSON.stringify({ focused: f, panes: list });
    exec("/bin/sh", ["-c", "cat > " + FILE + " <<'HERDR_EOF'\n" + body + "\nHERDR_EOF"]);
    const o = props();
    if (o && o.overlay) closeOverlay(o.overlay);
    return div();
  }
}
