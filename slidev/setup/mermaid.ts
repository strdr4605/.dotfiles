// Same Gruvbox light colors as pi/agent/skills/pr-visual-recap/scripts/upsert.mjs.
// Each diagram can still add `look: handDrawn` in its own config block.
const FONT = '"ComicCodeLigatures Nerd Font", "ComicCode Nerd Font", "Comic Sans MS", sans-serif'

export default () => ({
  theme: 'base',
  fontFamily: FONT,
  themeVariables: {
    background: '#fbf1c7',
    primaryColor: '#f9f5d7',
    primaryTextColor: '#3c3836',
    primaryBorderColor: '#7c6f64',
    secondaryColor: '#d5c4a1',
    tertiaryColor: '#f2e5bc',
    lineColor: '#665c54',
    textColor: '#3c3836',
    noteBkgColor: '#f2e5bc',
    noteBorderColor: '#b57614',
    fontFamily: FONT,
  },
})
