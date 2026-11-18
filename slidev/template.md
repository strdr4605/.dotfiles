---
theme: default
# The addon comes from <dotfiles>/slidev. Make a new deck with `slides-new <dir>`.
addons:
  - gruvbox
colorSchema: light
title: Lecture title
transition: slide-left
mdc: true
# The addon sets the font. Do not download Google fonts.
fonts:
  provider: none
---

# Lecture title

Course name · Week 1

---

# Agenda

<v-clicks>

- Topic one
- Topic two
- Topic three

</v-clicks>

---

# Code

```ts {1|2-3|all}
const students = await db.students.findMany()
const passed = students.filter(s => s.grade >= 5)
console.log(`${passed.length} passed => ok`)
```

---

# Diagram

```mermaid
---
config:
  look: handDrawn
  handDrawnSeed: 1
---
flowchart LR
  Idea --> Code --> Slides
```

---
layout: two-cols
---

# Left side

Text, bullets or an image.

::right::

![](https://sli.dev/logo.png)

---
layout: center
class: text-center
---

# Questions?
