<!-- Placeholder mascot to compare styles. The duck is only a stand-in: look and mood are props. -->
<script setup lang="ts">
const props = withDefaults(defineProps<{
  look?: 'doodle' | 'flat' | 'sticker' | 'chalk'
  mood?: 'hi' | 'think' | 'idea' | 'oops' | 'done'
  size?: number
}>(), { look: 'doodle', mood: 'hi', size: 220 })

const LOOKS = {
  doodle: { body: '#fabd2f', wing: '#fabd2f', beak: '#fe8019', ink: '#3c3836', line: 3, rough: true },
  flat: { body: '#d79921', wing: '#b57614', beak: '#d65d0e', ink: '#3c3836', line: 0, rough: false },
  sticker: { body: '#fabd2f', wing: '#fabd2f', beak: '#fe8019', ink: '#3c3836', line: 5, rough: false },
  chalk: { body: '#3c3836', wing: '#3c3836', beak: '#3c3836', ink: '#ebdbb2', line: 3, rough: true },
}

const c = LOOKS[props.look]
const filter = c.rough ? 'url(#mascot-rough)' : undefined
</script>

<template>
  <svg :width="size" :height="size * 220 / 240" viewBox="0 0 240 220" style="font-family: var(--gb-font)">
    <defs>
      <filter id="mascot-rough">
        <feTurbulence type="fractalNoise" baseFrequency="0.03" numOctaves="2" seed="3" />
        <feDisplacementMap in="SourceGraphic" scale="5" />
      </filter>
      <filter id="mascot-shadow">
        <feDropShadow dx="4" dy="6" stdDeviation="3" flood-color="#3c3836" flood-opacity="0.35" />
      </filter>
    </defs>

    <rect v-if="look === 'chalk'" x="2" y="2" width="236" height="216" rx="12" fill="#3c3836" stroke="#7c6f64" stroke-width="4" />

    <!-- Sticker look: a thick light outline and a shadow under the same shapes. -->
    <g v-if="look === 'sticker'" filter="url(#mascot-shadow)" stroke="#f9f5d7" stroke-width="22" stroke-linejoin="round" fill="#f9f5d7">
      <path d="M 45 135 L 25 112 L 55 125 Z" />
      <ellipse cx="110" cy="150" rx="70" ry="48" />
      <circle cx="135" cy="80" r="40" />
      <path d="M 168 82 Q 200 84 198 94 Q 190 104 166 98 Z" />
    </g>

    <g :filter="filter" :stroke="c.ink" :stroke-width="c.line" stroke-linejoin="round" stroke-linecap="round">
      <path d="M 45 135 L 25 112 L 55 125 Z" :fill="c.body" />
      <ellipse cx="110" cy="150" rx="70" ry="48" :fill="c.body" />
      <!-- The raised wing goes behind the head. -->
      <path v-if="mood === 'hi'" d="M 72 132 Q 55 90 85 68 Q 100 105 108 132" :fill="c.wing" />
      <circle cx="135" cy="80" r="40" :fill="c.body" />
      <path d="M 168 82 Q 200 84 198 94 Q 190 104 166 98 Z" :fill="c.beak" :stroke="look === 'chalk' ? '#fabd2f' : c.ink" />

      <path v-if="mood !== 'hi'" d="M 80 140 Q 110 122 142 145 Q 112 172 80 140 Z" :fill="c.wing" />

      <ellipse v-if="look === 'flat'" cx="142" cy="94" rx="9" ry="5" fill="#d3869b" stroke="none" />

      <!-- Eyes -->
      <g v-if="mood === 'oops'" :stroke-width="Math.max(c.line, 3)">
        <path d="M 141 66 L 153 78 M 153 66 L 141 78" />
      </g>
      <path v-else-if="mood === 'done'" d="M 139 76 Q 147 64 155 76" fill="none" :stroke-width="Math.max(c.line, 3)" />
      <g v-else>
        <circle :cx="mood === 'think' ? 143 : 147" :cy="mood === 'think' ? 66 : 72" :r="look === 'flat' ? 8 : 5" :fill="c.ink" stroke="none" />
        <circle v-if="look === 'flat'" :cx="mood === 'think' ? 146 : 150" :cy="mood === 'think' ? 63 : 69" r="2.5" fill="#fbf1c7" stroke="none" />
      </g>

      <!-- Mood extras, top left -->
      <g v-if="mood === 'think'">
        <circle cx="58" cy="45" r="28" :fill="look === 'chalk' ? 'none' : '#fbf1c7'" />
        <circle cx="92" cy="80" r="5" :fill="look === 'chalk' ? 'none' : '#fbf1c7'" />
        <path d="M 50 34 Q 50 22 60 22 Q 70 22 70 32 Q 70 40 60 44 L 60 52" fill="none" />
        <circle cx="60" cy="62" r="3" :fill="c.ink" />
      </g>
      <g v-if="mood === 'idea'">
        <circle cx="58" cy="42" r="20" fill="#fabd2f" />
        <path d="M 50 62 L 66 62 L 64 72 L 52 72 Z" fill="#928374" />
        <path d="M 58 8 L 58 14 M 28 42 L 22 42 M 88 42 L 94 42 M 36 20 L 32 16 M 80 20 L 84 16" fill="none" />
      </g>
      <path v-if="mood === 'oops'" d="M 104 48 Q 94 64 104 72 Q 114 64 104 48 Z" fill="#83a598" />
      <path v-if="mood === 'done'" d="M 28 45 L 48 66 L 90 18" fill="none" stroke="#79740e" stroke-width="9" />
    </g>
  </svg>
</template>
