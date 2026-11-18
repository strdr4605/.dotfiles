<!-- Draws one mascot persona in one look. Pixel and ASCII looks use their own components. -->
<script setup lang="ts">
const props = withDefaults(defineProps<{
  persona?: string
  look?: 'doodle' | 'flat' | 'sticker' | 'pixel' | 'ascii' | 'chalk'
  size?: number
}>(), { persona: 'duck', look: 'doodle', size: 220 })

const INK = '#3c3836'
const CHALK = '#ebdbb2'
const LIGHT = '#fbf1c7'

const LOOKS = {
  doodle: { line: 3, rough: true },
  flat: { line: 0, rough: false },
  sticker: { line: 5, rough: false },
  chalk: { line: 3, rough: true },
}

// Role colours for each persona. Role `line` is a stroke only. Role `ink` is the outline colour.
// Role `wire` is a thick stroke in the main colour.
const PALETTES = {
  duck: { main: '#fabd2f', shade: '#d79921', accent: '#fe8019', face: LIGHT, extra: '' },
  sloth: { main: '#a89984', shade: '#7c6f64', accent: '#d65d0e', face: '#ebdbb2', extra: '#79740e' },
  bug: { main: '#cc241d', shade: INK, accent: '#fabd2f', face: LIGHT, extra: '' },
  cat: { main: '#fe8019', shade: '#d65d0e', accent: '#d3869b', face: LIGHT, extra: '' },
  owl: { main: '#458588', shade: '#83a598', accent: '#fe8019', face: LIGHT, extra: '#fabd2f' },
  cursor: { main: '#98971a', shade: '#79740e', accent: '#fabd2f', face: LIGHT, extra: '' },
  panda: { main: '#ebdbb2', shade: INK, accent: '', face: LIGHT, extra: '' },
  bear: { main: '#af3a03', shade: '#d79921', accent: '', face: '#ebdbb2', extra: '' },
  koala: { main: '#928374', shade: '', accent: '', face: '#ebdbb2', extra: '' },
  clip: { main: '#427b58', shade: '', accent: '', face: LIGHT, extra: '' },
  stranger: { main: '#eac08f', shade: '#79740e', accent: '#b57614', face: '#076678', extra: '' },
  stranger1: { main: '#eac08f', shade: '#79740e', accent: '#cc241d', face: LIGHT, extra: '#458588' },
  stranger2: { main: '#eac08f', shade: '#79740e', accent: '#b57614', face: '#83a598', extra: '#928374' },
  stranger3: { main: '#eac08f', shade: '#79740e', accent: '#b57614', face: '#83a598', extra: '#928374' },
  stranger4: { main: '#eac08f', shade: '#79740e', accent: '#b57614', face: '#076678', extra: '' },
  stranger5: { main: '#eac08f', shade: '#79740e', accent: '#b57614', face: '#076678', extra: '' },
  pup: { main: '#d79921', shade: '#b57614', accent: '#458588', face: LIGHT, extra: '#d3869b' },
  byte: { main: '#b16286', shade: '#8f3f71', accent: '#d3869b', face: LIGHT, extra: '#fabd2f' },
}

const c = (cx: number, cy: number, r: number) => e(cx, cy, r, r)
const e = (cx: number, cy: number, rx: number, ry: number) =>
  `M ${cx - rx} ${cy} a ${rx} ${ry} 0 1 0 ${2 * rx} 0 a ${rx} ${ry} 0 1 0 ${-2 * rx} 0 Z`

type Role = 'main' | 'shade' | 'accent' | 'face' | 'extra' | 'ink' | 'line' | 'wire'

// Tilley LTM5 Airflo hat: round crown, mesh vent band near the top, brim that slopes down.
const TILLEY: [Role, string][] = [
  ['shade', 'M 86 86 Q 84 50 94 42 Q 120 34 146 42 Q 156 50 154 86 Z'],
  ['ink', 'M 87 54 Q 120 46 153 54 L 154 64 Q 120 56 86 64 Z'],
  ['shade', 'M 44 96 Q 58 76 120 78 Q 182 76 196 96 Q 200 104 190 103 Q 160 90 120 92 Q 80 90 50 103 Q 40 104 44 96 Z'],
]

// Parts are drawn in order: back to front. viewBox is 240 x 220.
const SHAPES: Record<string, [Role, string][]> = {
  duck: [
    ['main', 'M 45 135 L 25 112 L 55 125 Z'],
    ['main', e(110, 150, 70, 48)],
    ['main', c(135, 80, 40)],
    ['accent', 'M 168 82 Q 200 84 198 94 Q 190 104 166 98 Z'],
    ['shade', 'M 80 140 Q 110 122 142 145 Q 112 172 80 140 Z'],
    ['ink', c(147, 72, 5)],
  ],
  sloth: [
    ['extra', 'M 0 30 Q 120 18 240 34 L 240 46 Q 120 30 0 42 Z'],
    ['extra', 'M 190 36 Q 205 8 228 20 Q 212 40 190 36 Z'],
    ['main', e(95, 205, 14, 9)],
    ['main', e(145, 205, 14, 9)],
    ['main', 'M 72 130 Q 58 64 84 30 L 102 36 Q 84 72 94 130 Z'],
    ['main', 'M 168 130 Q 182 64 156 30 L 138 36 Q 156 72 146 130 Z'],
    ['line', 'M 84 26 q 6 10 0 18 M 94 28 q 6 10 0 18 M 146 28 q 6 10 0 18 M 156 26 q 6 10 0 18'],
    ['main', e(120, 160, 52, 50)],
    ['main', c(120, 100, 40)],
    ['face', e(120, 104, 32, 26)],
    ['shade', 'M 92 96 Q 100 84 114 98 Q 104 110 92 96 Z'],
    ['shade', 'M 148 96 Q 140 84 126 98 Q 136 110 148 96 Z'],
    ['ink', c(104, 97, 4)],
    ['ink', c(136, 97, 4)],
    ['ink', e(120, 110, 6, 4)],
    ['line', 'M 108 118 Q 120 126 132 118'],
  ],
  bug: [
    ['line', 'M 110 50 Q 98 22 80 18 M 130 50 Q 142 22 160 18'],
    ['ink', c(80, 18, 5)],
    ['ink', c(160, 18, 5)],
    ['line', 'M 72 110 L 40 96 M 68 140 L 34 140 M 72 170 L 40 186 M 168 110 L 200 96 M 172 140 L 206 140 M 168 170 L 200 186'],
    ['shade', c(120, 66, 26)],
    ['face', c(109, 60, 8)],
    ['face', c(131, 60, 8)],
    ['ink', c(110, 62, 3.5)],
    ['ink', c(132, 62, 3.5)],
    ['main', e(120, 140, 52, 62)],
    ['line', 'M 120 80 L 120 200'],
    ['shade', c(98, 118, 9)],
    ['shade', c(142, 118, 9)],
    ['shade', c(96, 160, 8)],
    ['shade', c(144, 160, 8)],
  ],
  cat: [
    ['main', 'M 160 185 Q 222 190 210 135 Q 206 118 220 108 Q 230 120 222 134 Q 234 198 160 200 Z'],
    ['main', e(120, 160, 55, 48)],
    ['face', e(120, 168, 26, 30)],
    ['main', 'M 82 72 L 78 22 L 115 52 Z'],
    ['main', 'M 158 72 L 162 22 L 125 52 Z'],
    ['accent', 'M 88 60 L 86 36 L 106 52 Z'],
    ['accent', 'M 152 60 L 154 36 L 134 52 Z'],
    ['main', e(120, 82, 48, 40)],
    ['shade', 'M 110 43 L 114 60 L 118 43 Z'],
    ['shade', 'M 122 43 L 126 60 L 130 43 Z'],
    ['ink', e(102, 80, 5, 7)],
    ['ink', e(138, 80, 5, 7)],
    ['accent', 'M 114 94 L 126 94 L 120 101 Z'],
    ['line', 'M 108 106 Q 114 112 120 102 Q 126 112 132 106'],
    ['line', 'M 70 90 L 94 96 M 70 104 L 94 102 M 170 90 L 146 96 M 170 104 L 146 102'],
    ['main', e(100, 204, 14, 8)],
    ['main', e(140, 204, 14, 8)],
  ],
  owl: [
    ['accent', e(102, 206, 11, 6)],
    ['accent', e(138, 206, 11, 6)],
    ['shade', 'M 62 120 Q 46 170 82 198 Q 74 160 74 120 Z'],
    ['shade', 'M 178 120 Q 194 170 158 198 Q 166 160 166 120 Z'],
    ['main', e(120, 135, 56, 70)],
    ['shade', e(120, 160, 36, 40)],
    ['line', 'M 104 150 q 6 6 12 0 M 124 150 q 6 6 12 0 M 114 170 q 6 6 12 0 M 104 188 q 6 6 12 0 M 124 188 q 6 6 12 0'],
    ['face', c(98, 102, 21)],
    ['face', c(142, 102, 21)],
    ['ink', c(101, 104, 8)],
    ['ink', c(139, 104, 8)],
    ['accent', 'M 112 120 L 128 120 L 120 136 Z'],
    ['ink', 'M 94 56 L 94 74 Q 120 84 146 74 L 146 56 Z'],
    ['ink', 'M 58 48 L 120 26 L 182 48 L 120 70 Z'],
    ['line', 'M 120 48 L 172 58 L 174 80'],
    ['extra', c(174, 86, 6)],
  ],
  cursor: [
    ['line', 'M 96 184 L 92 206 L 80 206 M 144 184 L 148 206 L 160 206'],
    ['main', 'M 72 36 H 168 Q 182 36 182 50 V 172 Q 182 186 168 186 H 72 Q 58 186 58 172 V 50 Q 58 36 72 36 Z'],
    ['face', c(100, 82, 13)],
    ['face', c(140, 82, 13)],
    ['ink', c(102, 84, 5)],
    ['ink', c(142, 84, 5)],
    ['line', 'M 108 106 Q 120 114 132 106'],
    ['line', 'M 90 134 L 104 146 L 90 158'],
    ['accent', 'M 114 136 H 130 V 160 H 114 Z'],
  ],
  panda: [
    ['shade', c(80, 48, 18)],
    ['shade', c(160, 48, 18)],
    ['shade', e(92, 205, 20, 12)],
    ['shade', e(148, 205, 20, 12)],
    ['main', e(120, 165, 58, 48)],
    ['shade', 'M 70 140 Q 60 175 90 185 Q 98 160 92 135 Z'],
    ['shade', 'M 170 140 Q 180 175 150 185 Q 142 160 148 135 Z'],
    ['main', e(120, 90, 52, 44)],
    ['shade', 'M 88 92 Q 86 70 104 74 Q 114 84 106 100 Q 94 108 88 92 Z'],
    ['shade', 'M 152 92 Q 154 70 136 74 Q 126 84 134 100 Q 146 108 152 92 Z'],
    ['face', c(101, 86, 5)],
    ['face', c(139, 86, 5)],
    ['ink', e(120, 104, 7, 5)],
    ['line', 'M 112 112 Q 120 118 128 112'],
  ],
  bear: [
    ['main', c(78, 50, 18)],
    ['main', c(162, 50, 18)],
    ['shade', c(78, 50, 9)],
    ['shade', c(162, 50, 9)],
    ['main', e(92, 205, 18, 11)],
    ['main', e(148, 205, 18, 11)],
    ['main', e(120, 165, 56, 48)],
    ['shade', e(120, 172, 30, 30)],
    ['main', e(120, 90, 50, 42)],
    ['face', e(120, 106, 22, 16)],
    ['ink', c(100, 84, 5)],
    ['ink', c(140, 84, 5)],
    ['ink', e(120, 99, 8, 5)],
    ['line', 'M 120 104 L 120 112 M 110 112 Q 120 120 130 112'],
  ],
  koala: [
    ['main', c(70, 62, 30)],
    ['main', c(170, 62, 30)],
    ['face', c(72, 64, 16)],
    ['face', c(168, 64, 16)],
    ['main', e(94, 205, 16, 10)],
    ['main', e(146, 205, 16, 10)],
    ['main', e(120, 168, 52, 44)],
    ['face', e(120, 175, 26, 28)],
    ['main', e(120, 98, 48, 42)],
    ['ink', c(100, 92, 4.5)],
    ['ink', c(140, 92, 4.5)],
    ['ink', e(120, 106, 11, 15)],
    ['line', 'M 112 126 Q 120 130 128 126'],
  ],
  clip: [
    ['wire', 'M 110 150 V 70 Q 110 55 122 55 Q 134 55 134 70 V 175 Q 134 198 113 198 Q 92 198 92 175 V 50 Q 92 22 122 22 Q 152 22 152 50 V 160'],
    ['face', c(101, 96, 13)],
    ['face', c(143, 96, 13)],
    ['ink', c(103, 99, 5)],
    ['ink', c(141, 99, 5)],
    ['line', 'M 114 96 Q 122 90 130 96'],
    ['line', 'M 112 124 Q 122 132 132 124'],
  ],
  byte: [
    ['line', 'M 120 42 L 120 20'],
    ['extra', c(120, 14, 8)],
    ['shade', 'M 92 176 H 108 V 206 H 88 Z'],
    ['shade', 'M 132 176 H 148 V 206 H 128 Z'],
    ['main', 'M 60 100 Q 60 40 120 40 Q 180 40 180 100 V 160 Q 180 186 154 186 H 86 Q 60 186 60 160 Z'],
    ['shade', 'M 60 152 H 180 V 160 Q 180 186 154 186 H 86 Q 60 186 60 160 Z'],
    ['face', c(98, 100, 15)],
    ['face', c(142, 100, 15)],
    ['ink', c(100, 103, 6)],
    ['ink', c(140, 103, 6)],
    ['accent', e(82, 128, 8, 5)],
    ['accent', e(158, 128, 8, 5)],
    ['line', 'M 110 128 Q 120 136 130 128'],
  ],
  stranger: [
    ['face', 'M 50 218 Q 52 160 120 156 Q 188 160 190 218 Z'],
    ['main', 'M 106 138 H 134 V 160 Q 120 170 106 160 Z'],
    ['main', e(80, 112, 7, 11)],
    ['main', e(160, 112, 7, 11)],
    ['main', e(120, 110, 40, 44)],
    // Short round beard. The thin moustache touches the beard only on the right.
    ['accent', 'M 82 100 Q 80 142 98 156 Q 120 168 142 156 Q 160 142 158 100 Q 150 120 139 129 Q 138 142 128 146 Q 120 144 112 146 Q 102 142 100 132 Q 90 122 82 100 Z'],
    ['ink', c(104, 112, 4.5)],
    ['ink', c(136, 112, 4.5)],
    ['line', 'M 96 101 Q 103 97 110 100 M 130 100 Q 137 97 144 101'],
    ['line', 'M 120 112 Q 115 124 122 126'],
    ['accent', 'M 102 138 Q 105 128 120 129 Q 135 128 138 138 Q 130 141 120 139 Q 110 141 102 138 Z'],
    ['line', 'M 112 143 Q 120 147 129 142'],
    ...TILLEY,
  ],
  // Earlier versions of the stranger, kept to compare.
  // 1: cowboy hat, bandana, no beard.
  stranger1: [
    ['extra', 'M 50 218 Q 52 160 120 156 Q 188 160 190 218 Z'],
    ['main', 'M 106 138 H 134 V 166 H 106 Z'],
    ['accent', 'M 90 152 Q 120 168 150 152 L 120 192 Z'],
    ['main', e(80, 112, 7, 11)],
    ['main', e(160, 112, 7, 11)],
    ['main', e(120, 110, 40, 44)],
    ['ink', c(104, 112, 4.5)],
    ['ink', c(136, 112, 4.5)],
    ['line', 'M 96 102 L 110 104 M 144 102 L 130 104'],
    ['line', 'M 120 114 Q 115 126 122 128'],
    ['line', 'M 108 138 Q 120 144 134 133'],
    ['shade', 'M 84 84 Q 82 40 104 36 Q 120 46 136 36 Q 158 40 156 84 Z'],
    ['ink', 'M 84 72 Q 120 80 156 72 L 156 82 Q 120 90 84 82 Z'],
    ['shade', 'M 40 84 Q 60 98 120 94 Q 180 98 200 84 Q 210 76 196 74 Q 160 90 120 86 Q 80 90 44 74 Q 30 76 40 84 Z'],
  ],
  // 2: Tilley hat, pointed beard, shirt and vest, angry brows.
  stranger2: [
    ['face', 'M 50 218 Q 52 160 120 156 Q 188 160 190 218 Z'],
    ['extra', 'M 50 218 Q 52 162 98 157 L 110 218 Z'],
    ['extra', 'M 190 218 Q 188 162 142 157 L 130 218 Z'],
    ['main', 'M 106 138 H 134 V 166 H 106 Z'],
    ['face', 'M 104 160 L 120 174 L 106 186 Z'],
    ['face', 'M 136 160 L 120 174 L 134 186 Z'],
    ['main', e(80, 112, 7, 11)],
    ['main', e(160, 112, 7, 11)],
    ['main', e(120, 110, 40, 44)],
    ['accent', 'M 82 104 Q 78 152 120 172 Q 162 152 158 104 Q 152 128 140 128 Q 120 120 100 128 Q 88 128 82 104 Z'],
    ['ink', c(104, 112, 4.5)],
    ['ink', c(136, 112, 4.5)],
    ['line', 'M 96 102 L 110 104 M 144 102 L 130 104'],
    ['line', 'M 120 112 Q 115 124 122 126'],
    ['accent', 'M 102 137 Q 110 126 120 131 Q 130 126 138 137 Q 120 134 102 137 Z'],
    ['line', 'M 110 143 Q 120 147 131 140'],
    ...TILLEY,
  ],
  // 3: as 2, soft brows.
  stranger3: [
    ['face', 'M 50 218 Q 52 160 120 156 Q 188 160 190 218 Z'],
    ['extra', 'M 50 218 Q 52 162 98 157 L 110 218 Z'],
    ['extra', 'M 190 218 Q 188 162 142 157 L 130 218 Z'],
    ['main', 'M 106 138 H 134 V 166 H 106 Z'],
    ['face', 'M 104 160 L 120 174 L 106 186 Z'],
    ['face', 'M 136 160 L 120 174 L 134 186 Z'],
    ['main', e(80, 112, 7, 11)],
    ['main', e(160, 112, 7, 11)],
    ['main', e(120, 110, 40, 44)],
    ['accent', 'M 82 104 Q 78 152 120 172 Q 162 152 158 104 Q 152 128 140 128 Q 120 120 100 128 Q 88 128 82 104 Z'],
    ['ink', c(104, 112, 4.5)],
    ['ink', c(136, 112, 4.5)],
    ['line', 'M 96 101 Q 103 97 110 100 M 130 100 Q 137 97 144 101'],
    ['line', 'M 120 112 Q 115 124 122 126'],
    ['accent', 'M 100 137 Q 110 128 120 132 Q 130 128 140 137 Q 130 136 120 135 Q 110 136 100 137 Z'],
    ['line', 'M 110 143 Q 120 147 131 140'],
    ...TILLEY,
  ],
  // 4: t-shirt, thin chin-strap beard, split moustache, one patch.
  stranger4: [
    ['face', 'M 50 218 Q 52 160 120 156 Q 188 160 190 218 Z'],
    ['main', 'M 106 138 H 134 V 160 Q 120 170 106 160 Z'],
    ['line', 'M 102 157 Q 120 175 138 157'],
    ['main', e(80, 112, 7, 11)],
    ['main', e(160, 112, 7, 11)],
    ['main', e(120, 110, 40, 44)],
    ['accent', 'M 82 104 Q 80 142 98 156 Q 120 168 142 156 Q 160 142 158 104 Q 150 126 144 134 Q 142 148 130 148 Q 120 145 110 148 Q 98 148 96 134 Q 90 126 82 104 Z'],
    ['ink', c(104, 112, 4.5)],
    ['ink', c(136, 112, 4.5)],
    ['line', 'M 96 101 Q 103 97 110 100 M 130 100 Q 137 97 144 101'],
    ['line', 'M 120 112 Q 115 124 122 126'],
    ['accent', 'M 104 134 Q 110 128 118 131 L 118 134 Q 110 133 104 134 Z'],
    ['accent', 'M 136 134 Q 130 128 122 131 L 122 134 Q 130 133 136 134 Z'],
    ['accent', e(141, 137, 3, 2.5)],
    ['line', 'M 111 140 Q 120 144 130 138'],
    ...TILLEY,
  ],
  // 5: fuller short beard, split moustache.
  stranger5: [
    ['face', 'M 50 218 Q 52 160 120 156 Q 188 160 190 218 Z'],
    ['main', 'M 106 138 H 134 V 160 Q 120 170 106 160 Z'],
    ['main', e(80, 112, 7, 11)],
    ['main', e(160, 112, 7, 11)],
    ['main', e(120, 110, 40, 44)],
    ['accent', 'M 82 100 Q 80 142 98 156 Q 120 168 142 156 Q 160 142 158 100 Q 150 120 139 129 Q 138 142 128 146 Q 120 144 112 146 Q 102 142 100 132 Q 90 122 82 100 Z'],
    ['ink', c(104, 112, 4.5)],
    ['ink', c(136, 112, 4.5)],
    ['line', 'M 96 101 Q 103 97 110 100 M 130 100 Q 137 97 144 101'],
    ['line', 'M 120 112 Q 115 124 122 126'],
    ['accent', 'M 104 134 Q 110 128 118 131 L 118 134 Q 110 133 104 134 Z'],
    ['accent', 'M 136 134 Q 130 128 122 131 L 122 134 Q 130 133 136 134 Z'],
    ['line', 'M 111 140 Q 120 144 130 138'],
    ...TILLEY,
  ],
  pup: [
    ['main', 'M 160 192 Q 200 188 206 148 Q 214 144 216 152 Q 212 198 162 206 Z'],
    ['main', e(84, 196, 26, 16)],
    ['main', e(156, 196, 26, 16)],
    ['main', e(120, 160, 44, 50)],
    ['face', e(120, 168, 22, 30)],
    ['line', 'M 104 176 L 104 204 M 136 176 L 136 204'],
    ['main', e(104, 208, 12, 8)],
    ['main', e(136, 208, 12, 8)],
    ['accent', 'M 86 112 Q 120 128 154 112 L 152 124 Q 120 140 88 124 Z'],
    ['shade', c(120, 138, 6)],
    ['main', e(120, 80, 44, 40)],
    ['shade', 'M 84 56 Q 56 58 58 120 Q 70 130 84 112 Q 82 80 94 62 Z'],
    ['shade', 'M 156 56 Q 184 58 182 120 Q 170 130 156 112 Q 158 80 146 62 Z'],
    ['shade', e(139, 74, 15, 13)],
    ['face', c(102, 76, 9)],
    ['face', c(138, 76, 9)],
    ['ink', c(104, 74, 4.5)],
    ['ink', c(140, 74, 4.5)],
    ['face', e(120, 102, 20, 14)],
    ['extra', 'M 113 108 Q 113 122 120 122 Q 127 122 127 108 Z'],
    ['ink', e(120, 94, 8, 6)],
    ['line', 'M 120 98 L 120 106 M 110 106 Q 120 112 130 106'],
  ],
}

const svgLook = props.look in LOOKS
const look = LOOKS[props.look as keyof typeof LOOKS] ?? LOOKS.doodle
const palette = PALETTES[props.persona]
const chalk = props.look === 'chalk'
const filter = look.rough ? 'url(#mascot-rough)' : undefined

const parts = SHAPES[props.persona].flatMap(([role, d]) => {
  if (role === 'wire') {
    const core = { d, fill: 'none', stroke: chalk ? CHALK : palette.main, width: chalk ? 4 : 9 }
    return look.line && !chalk ? [{ d, fill: 'none', stroke: INK, width: 9 + 2 * look.line }, core] : [core]
  }

  if (role === 'line')
    return [{ d, fill: 'none', stroke: chalk ? CHALK : INK, width: Math.max(look.line, 3) }]

  if (role === 'ink')
    return [{ d, fill: chalk ? CHALK : INK, stroke: 'none', width: 0 }]

  return [{
    d,
    fill: chalk ? INK : palette[role],
    stroke: chalk ? CHALK : INK,
    width: look.line,
  }]
})
</script>

<template>
  <PixelMascot v-if="props.look === 'pixel'" :persona="persona" :size="size * 0.8" />
  <AsciiMascot v-else-if="props.look === 'ascii'" :persona="persona" :size="size" />

  <svg v-else-if="svgLook" :width="size" :height="size * 220 / 240" viewBox="0 0 240 220">
    <defs>
      <filter id="mascot-rough">
        <feTurbulence type="fractalNoise" baseFrequency="0.03" numOctaves="2" seed="3" />
        <feDisplacementMap in="SourceGraphic" scale="5" />
      </filter>
      <filter id="mascot-shadow">
        <feDropShadow dx="4" dy="6" stdDeviation="3" :flood-color="INK" flood-opacity="0.35" />
      </filter>
    </defs>

    <rect v-if="chalk" x="2" y="2" width="236" height="216" rx="12" :fill="INK" stroke="#7c6f64" stroke-width="4" />

    <!-- Sticker look: a thick light outline and a shadow under the same shapes. -->
    <g v-if="props.look === 'sticker'" filter="url(#mascot-shadow)" :stroke="LIGHT" stroke-width="22" stroke-linejoin="round" stroke-linecap="round">
      <path v-for="(p, i) in parts" :key="i" :d="p.d" :fill="p.fill === 'none' ? 'none' : LIGHT" />
    </g>

    <g :filter="filter" stroke-linejoin="round" stroke-linecap="round">
      <path
        v-for="(p, i) in parts" :key="i"
        :d="p.d" :fill="p.fill" :stroke="p.width ? p.stroke : 'none'" :stroke-width="p.width"
      />
    </g>
  </svg>
</template>
