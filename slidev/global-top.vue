<!-- Shows the author handle on each slide when the deck frontmatter has `footer: true`. -->
<!-- global-top, not global-bottom: Slidev draws global-bottom behind the slide background. -->
<template>
  <div
    v-if="$slidev.configs.footer"
    class="absolute bottom-3 right-5 text-sm opacity-60"
    style="color: var(--gb-gray); font-family: var(--gb-font)"
  >
    @strdr4605
  </div>
</template>
