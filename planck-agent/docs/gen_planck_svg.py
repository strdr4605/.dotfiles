#!/usr/bin/env python3
"""
Generate a Planck EZ keyboard SVG driven by ~/.config/planck-agent/config.json.

Color rules (per planck-agent):
  Row 0 (Tab Q-P Bksp, 12 keys) — agent state colours
    : 5 live agents + 7 unused ("white" = no glow)
  Row 1 (Esc A-L ; ')         — per-config colour from keys.*
  Row 2 (Shift Z-/ Enter)     — per-config colour from keys.*
  Thumbs                       — modifiers neutral; Space = worst agent state
"""

from pathlib import Path
import json
import subprocess
import uuid
import svgwrite

# ----------------------- Planck layout -----------------------
KEY_W = 60
KEY_H = 60
GAP = 6
PAD_X = 30
PAD_TOP = 56
PAD_BOTTOM = 30
THUMB_GAP = GAP   # same row spacing between thumb row and alpha rows

COLS = 12

# 3 alpha rows × 12 columns
ROW_LABELS = [
    # Row 0 — Tab Q-P Bksp — agent slots in planck-agent layer
    ['Tab', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Bksp'],
    # Row 1 — Esc A-L ; '
    ['Esc', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', "'"],
    # Row 2 — Shift Z-/ Enter
    ['Shift', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', 'Enter'],
]

# Row 3 — thumb cluster with 2u Space at cols 5-6
THUMB_LAYOUT = [
    ('Shift', 1),
    ('Ctrl',  1),
    ('Alt',   1),
    ('OS',    1),
    ('Lower', 1),
    ('Space', 2),
    ('Raise', 1),
    ('◁',     1),
    ('▽',     1),
    ('▷',     1),
    ('↵',     1),
]
assert sum(w for _, w in THUMB_LAYOUT) == COLS
assert len(THUMB_LAYOUT) == 11

# ----------------------- planck-agent config -----------------------
CONFIG_PATH = Path.home() / '.config' / 'planck-agent' / 'config.json'

def load_planck_agent_config():
    if not CONFIG_PATH.exists():
        print(f'warning: {CONFIG_PATH} not found, falling back to defaults')
        return {}
    with CONFIG_PATH.open() as f:
        return json.load(f)

CFG = load_planck_agent_config()

# Agent row state sequence, 12 entries (one per column 0-11).
# 5 active slots in different states, 7 unused (None = no glow).
AGENT_ROW_STATES = [
    'working',   # 0  Tab
    'idle',      # 1  Q
    'idle',      # 2  W
    'done',      # 3  E
    'blocked',   # 4  R
    None, None, None, None, None, None, None,  # 5-11 unused
]

# Resolve agent-state colours from config.colors; allow fallback defaults.
def _state_color(state):
    if state is None:
        return None  # white / unused
    return CFG.get('colors', {}).get(state) or {
        'blocked': '#ff0000',
        'working': '#ffa500',
        'done':    '#0000ff',
        'idle':    '#00ff00',
        'empty':   '#202020',
    }.get(state)

# Per-key colour from config.keys; None if no entry.
CONFIG_KEY_ALIASES = {
    'esc':    'escape',
    "'":      "'",
    ',':      ',',
    ';':      ';',
    '/':      '/',
    '.':      '.',
}

def key_color(label):
    """Return the per-key glow colour, or None for white (no glow)."""
    if not label:
        return None
    name = CONFIG_KEY_ALIASES.get(label.lower(), label.lower())
    entry = CFG.get('keys', {}).get(name)
    return entry.get('color') if entry else None

# ----------------------- Dimensions -----------------------
ROWS = 3
main_w = COLS * KEY_W + (COLS - 1) * GAP
board_w = PAD_X * 2 + main_w
board_h = (
    PAD_TOP + ROWS * KEY_H + (ROWS - 1) * GAP
    + THUMB_GAP + KEY_H + PAD_BOTTOM
)
main_x0 = PAD_X
main_y0 = PAD_TOP
thumb_y0 = main_y0 + ROWS * KEY_H + (ROWS - 1) * GAP + THUMB_GAP
thumb_x0 = PAD_X

# ----------------------- SVG -----------------------
dwg = svgwrite.Drawing(
    filename='planck.svg',
    size=(board_w, board_h),
    viewBox=f"0 0 {board_w} {board_h}",
)

# Filters
glow_small = dwg.defs.add(dwg.filter(id='glow-s', x='-60%', y='-60%',
                                      width='220%', height='220%'))
glow_small.feGaussianBlur(in_='SourceGraphic', stdDeviation='3')

glow_med = dwg.defs.add(dwg.filter(id='glow-m', x='-100%', y='-100%',
                                    width='300%', height='300%'))
glow_med.feGaussianBlur(in_='SourceGraphic', stdDeviation='3')

cap_shadow = dwg.defs.add(dwg.filter(
    id='cap-shadow', x='-20%', y='-20%', width='140%', height='140%'
))
cap_shadow.feGaussianBlur(in_='SourceAlpha', stdDeviation=1.5)
cap_shadow.feOffset(dx=0, dy=1.5, result='off')
cap_shadow.feFlood(flood_color='#000000', flood_opacity=0.18)
cap_shadow.feComposite(in_='SourceGraphic', in2='off', operator='over')

# Case — pure white (Planck EZ white edition).
dwg.add(dwg.rect(
    insert=(0, 0), size=(board_w, board_h),
    rx=20, ry=20, fill='#ffffff', stroke='#d8d8de', stroke_width=1.5,
))
dwg.add(dwg.rect(
    insert=(8, 8), size=(board_w - 16, board_h - 16),
    rx=14, ry=14, fill='#ffffff', stroke='none',
))

# White PCB substrate behind the cap grid.  Visible in gaps between keys.
# For unlit keys the cap cutouts reveal this white layer too, so the
# legends read as "white-on-white" = effectively a blank white cap.
# For lit keys the per-key LED rect sits on top of this and shines through
# the cutouts.
PCB_PAD = 8
pcb_x = main_x0 - PCB_PAD
pcb_y = main_y0 - PCB_PAD
pcb_w = main_w + 2 * PCB_PAD
pcb_h = (thumb_y0 - main_y0) + KEY_H + 2 * PCB_PAD
dwg.add(dwg.rect(
    insert=(pcb_x, pcb_y), size=(pcb_w, pcb_h),
    rx=14, ry=14, fill='#ffffff', stroke='#e0e0e6', stroke_width=1,
))
dwg.add(dwg.text(
    'OLKB  PLANCK  EZ',
    insert=(board_w / 2, 32),
    text_anchor='middle',
    font_family='Helvetica, Arial, sans-serif',
    font_size=12, font_weight='bold', letter_spacing=4,
    fill='#5a5a66',
))
# Status LED
led_x, led_y = board_w - 36, 24
dwg.add(dwg.circle(
    center=(led_x, led_y), r=4,
    fill=_state_color('blocked') or '#ff0000',
    filter='url(#glow-m)',
))

# ---- Key renderer ----
def draw_key(x, y, w, label, color):
    """Draw a keycap at (x,y) with given width-in-u.

    color: per-key RGB glow colour, or None for "white / unlit" key.

    Visual stack, from bottom up:
      PCB dark substrate (added once)         -> visible through letter cutouts
      LED pad (only if color given)           -> the lit color under the cap
      Tight glow halo (only if color given)   -> bloom around the cap
      White cap with letter-shaped cutout     -> letters are transparent
    """
    pixel_w = w * KEY_W + (w - 1) * GAP

    if color is not None:
        # LED underlay: the actual "lit" area the letter cutouts reveal.
        dwg.add(dwg.rect(
            insert=(x - 2, y - 2),
            size=(pixel_w + 4, KEY_H + 4),
            rx=11, ry=11,
            fill=color,
        ))
        # Tight glow halo — small oversize and small blur.
        dwg.add(dwg.rect(
            insert=(x - 5, y - 5),
            size=(pixel_w + 10, KEY_H + 10),
            rx=13, ry=13,
            fill=color,
            opacity=0.75,
            filter='url(#glow-s)',
        ))

    # White keycap with letter cutouts.
    mask_id = f'm-{uuid.uuid4().hex[:8]}'
    m = dwg.defs.add(dwg.mask(id=mask_id))
    m.add(dwg.rect(
        insert=(x, y), size=(pixel_w, KEY_H),
        rx=10, ry=10, fill='#ffffff',
    ))
    font_size = 18 if len(label) <= 2 else (14 if len(label) <= 4 else 12)
    m.add(dwg.text(
        label,
        insert=(x + pixel_w / 2, y + KEY_H / 2 + font_size / 3),
        text_anchor='middle',
        font_family='Helvetica, Arial, sans-serif',
        font_size=font_size,
        font_weight='bold',
        fill='#000000',
    ))

    dwg.add(dwg.rect(
        insert=(x, y), size=(pixel_w, KEY_H),
        rx=10, ry=10,
        fill='#f8f8fb',
        stroke='#cfcfd6',
        stroke_width=1,
        filter='url(#cap-shadow)',
        mask=f'url(#{mask_id})',
    ))

# ---- Draw main grid ----
# Row 0 — agent row (uses agent-state colours)
for c, label in enumerate(ROW_LABELS[0]):
    color = _state_color(AGENT_ROW_STATES[c])
    draw_key(
        main_x0 + c * (KEY_W + GAP),
        main_y0,
        w=1, label=label, color=color,
    )

# Row 1 — per-config (Esc A-L ; ')
for c, label in enumerate(ROW_LABELS[1]):
    color = key_color(label)
    draw_key(
        main_x0 + c * (KEY_W + GAP),
        main_y0 + 1 * (KEY_H + GAP),
        w=1, label=label, color=color,
    )

# Row 2 — per-config (Shift Z-/ Enter)
for c, label in enumerate(ROW_LABELS[2]):
    color = key_color(label)
    draw_key(
        main_x0 + c * (KEY_W + GAP),
        main_y0 + 2 * (KEY_H + GAP),
        w=1, label=label, color=color,
    )

# Thumbs — modifiers neutral, Space = "worst" agent state (blocked)
WORST_AGENT_COLOR = _state_color('blocked') or '#ff0000'

x_cursor = thumb_x0
for label, w in THUMB_LAYOUT:
    if label == 'Space':
        color = WORST_AGENT_COLOR
    else:
        color = None  # neutral / white
    draw_key(x_cursor, thumb_y0, w=w, label=label, color=color)
    x_cursor += w * KEY_W + (w - 1) * GAP + GAP

# ---- Save ----
out_svg = Path('planck.svg')
dwg.saveas(str(out_svg))
print(f'Wrote {out_svg} ({board_w}x{board_h})')

subprocess.run(
    ['rsvg-convert', '-w', str(board_w), '-h', str(board_h),
     str(out_svg), '-o', 'planck.png'],
    check=True,
)
print('Wrote planck.png')
