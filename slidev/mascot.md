---
theme: default
addons:
  - gruvbox
colorSchema: light
footer: true
title: Mascot options
transition: slide-left
mdc: true
fonts:
  provider: none
---

# Mascot options

Style, persona, sprite frames. The duck is only a stand-in.

---

# All personas × all styles

<div class="grid grid-cols-[auto_repeat(13,1fr)] gap-x-1 items-center justify-items-center text-xs">
  <div></div>
  <div v-for="p in ['duck','sloth','bug','cat','owl','cursor','panda','bear','koala','clip','byte','stranger','pup']" :key="p">{{ p }}</div>
  <template v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l">
    <div class="justify-self-end">{{ l }}</div>
    <div v-for="p in ['duck','sloth','bug','cat','owl','cursor','panda','bear','koala','clip','byte','stranger','pup']" :key="p" class="h-[64px] flex items-center"><Mascot :persona="p" :look="l" :size="54" /></div>
  </template>
</div>

---

# Rubber duck

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="duck" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Sloth

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="sloth" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Bug

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="bug" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Cat

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="cat" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Owl

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="owl" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Cursor blob

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="cursor" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Panda

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="panda" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Bear

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="bear" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Koala

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="koala" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Paper clip

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="clip" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Byte (own robot)

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="byte" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Stranger (you)

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="stranger" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Stranger versions

<div class="grid grid-cols-[auto_repeat(6,1fr)] gap-x-2 items-center justify-items-center text-xs">
  <div></div>
  <div v-for="v in ['v1 cowboy','v2 Tilley, vest','v3 soft brows','v4 t-shirt','v5 fuller beard','v6 current']" :key="v">{{ v }}</div>
  <template v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l">
    <div class="justify-self-end">{{ l }}</div>
    <div v-for="p in ['stranger1','stranger2','stranger3','stranger4','stranger5','stranger']" :key="p" class="h-[64px] flex items-center"><Mascot :persona="p" :look="l" :size="58" /></div>
  </template>
</div>

---

# Pup

<div class="grid grid-cols-3 gap-x-6 gap-y-2 text-center text-sm">
  <div v-for="l in ['doodle','flat','sticker','pixel','ascii','chalk']" :key="l" class="flex flex-col items-center justify-end h-[200px]">
    <Mascot persona="pup" :look="l" :size="180" />
    <div>{{ l }}</div>
  </div>
</div>

---

# Style trade-offs

| # | Style | Matches | Cost to make new frames |
|---|---|---|---|
| 1 | Doodle | handDrawn Mermaid, Comic Code | low: SVG + wobble filter |
| 2 | Flat kawaii | Gruvbox colours | low: plain SVG |
| 3 | Sticker | fun, reads well on projector | low: SVG + outline |
| 4 | Pixel art | retro Gruvbox, dev vibe | medium: draw each frame by hand |
| 5 | ASCII | Comic Code, code blocks | lowest: type it |
| 6 | Chalkboard | teacher, university | low, but dark box on light slide |

---

# Persona options

| Persona | Role on the slides |
|---|---|
| Rubber duck | Asks the "dumb" question. Debugging buddy. |
| Sloth | Lazy-teacher alter ego. "Do less" tips. |
| Bug (beetle) | Shows up on pitfalls and common mistakes. |
| Cat | Sits on the keyboard. Sarcastic side notes. |
| Owl | Wise TA. Quizzes and summaries. |
| Cursor blob `▌` | Lives in the terminal. Font-native. |
| Panda | Calm. "Take a break" and recap slides. |
| Bear | Big and strong. Hard topics, "bear with me". |
| Koala | Sleeps 20 h a day. Another lazy-teacher option. |
| Paper clip | Office-assistant joke. Pops in with tips nobody asked for. |
| Byte | Your own little robot. Runs the demos. |
| Stranger | You: olive Tilley hat, short blonde-to-brown beard, thin moustache, dark t-shirt. Your surname means "stranger". |
| Pup | Search-dog joke. Fetches the answer. Own look: blue collar, eye patch. |

---

# Sprite frames (doodle)

<div class="grid grid-cols-5 gap-2 text-center text-sm mt-8">
  <div><MascotDuck mood="hi" :size="150" /><div>hi · title</div></div>
  <div><MascotDuck mood="think" :size="150" /><div>think · question</div></div>
  <div><MascotDuck mood="idea" :size="150" /><div>idea · tip</div></div>
  <div><MascotDuck mood="oops" :size="150" /><div>oops · pitfall</div></div>
  <div><MascotDuck mood="done" :size="150" /><div>done · summary</div></div>
</div>

---

# Sprite frames (sticker)

<div class="grid grid-cols-5 gap-2 text-center text-sm mt-8">
  <div><MascotDuck look="sticker" mood="hi" :size="150" /><div>hi</div></div>
  <div><MascotDuck look="sticker" mood="think" :size="150" /><div>think</div></div>
  <div><MascotDuck look="sticker" mood="idea" :size="150" /><div>idea</div></div>
  <div><MascotDuck look="sticker" mood="oops" :size="150" /><div>oops</div></div>
  <div><MascotDuck look="sticker" mood="done" :size="150" /><div>done</div></div>
</div>

---
layout: two-cols
---

# In a real slide

Use `mood` to match the slide.

- `<MascotDuck mood="oops" />` on a pitfall
- `<MascotDuck mood="think" />` on a quiz

::right::

<MascotDuck mood="oops" :size="300" class="mx-auto mt-16" />
