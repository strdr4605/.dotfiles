<!-- ASCII mascots in the deck font. -->
<script setup lang="ts">
withDefaults(defineProps<{
  persona?: string
  size?: number
}>(), { persona: 'duck', size: 220 })

const ART: Record<string, string> = {
  duck: String.raw`
    __
___( o)>
\ <_. )
 '---'`,
  sloth: String.raw`
=============
  \ ____ /
  ( -.- )
  (  ~  )
   U   U`,
  bug: String.raw`
  \   /
  (o o)
 /(_|_)\
-( o|o )-
 \(_|_)/`,
  cat: String.raw`
 /\_/\
( o.o )
 > ^ <
(")_(")~`,
  owl: String.raw`
 _[__]_
 {o,o}
 |)__)
 -"-"-`,
  cursor: String.raw`
╭───────╮
│ ●   ● │
│   ‿   │
│ > ▌   │
╰─┬───┬─╯
  ╯   ╰`,
  panda: String.raw`
 ()___()
 (@ . @)
 (  -  )
 (")_(")`,
  bear: String.raw`
 (\_____/)
  ( o   o )
  (  (_)  )
   (")_(")`,
  koala: String.raw`
@( o   o )@
   ( () )
   (    )
   (")(")`,
  clip: String.raw`
  .----.
 / .--. \
| (o)(o) |
| |  | | |
| '--' | |
 \_____/ |`,
  byte: String.raw`
    o
  .-|-.
 ( O O )
 ( \_/ )
  '---'
   ┘ └`,
  stranger: String.raw`
     ______
    |######|
  __|______|__
 /____________\
    ( o  o )
    (%~~~~%)
     (%%%%)`,
  pup: String.raw`
 ,-~-.___.-~-,
(  /       \  )
 \/  o   o  \/
  |    T    |
   \  \_/  /
    '=[o]='
   (___|___)~`,
}

// Earlier versions of the stranger, kept to compare.
const STRANGER_V2 = String.raw`
     ______
    |######|
  __|______|__
 /____________\
    ( o  o )
    (%~~~~%)
     \%%%%/
      \%%/`
const STRANGER_V4 = String.raw`
     ______
    |######|
  __|______|__
 /____________\
    ( o  o )
    (% ~~ %)
     (%%%%)`
Object.assign(ART, {
  stranger1: String.raw`
     ____
  __|____|__
  \________/
   ( -  - )
    \ ~  /
   /|____|\ `,
  stranger2: STRANGER_V2,
  stranger3: STRANGER_V2,
  stranger4: STRANGER_V4,
  stranger5: STRANGER_V4,
})
</script>

<template>
  <pre
    class="!bg-transparent !m-0 leading-tight"
    :style="{ fontSize: `${size / 11}px`, fontFamily: 'var(--gb-font)', color: '#3c3836', fontVariantLigatures: 'none' }"
  >{{ ART[persona].slice(1) }}</pre>
</template>
