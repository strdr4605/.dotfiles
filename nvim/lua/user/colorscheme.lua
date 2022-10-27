-- gruvbox
vim.g.gruvbox_bold = 0
vim.opt.termguicolors = true
vim.o.background = "dark" -- or "light" for light mode
require("gruvbox").setup({
  contrast = "hard", -- can be "hard", "soft" or empty string
  transparent_mode = true,
})
require("tokyonight").setup({
  transparent = true,
})

local colors = require('ayu.colors')
colors.generate(true) -- Pass `true` to enable mirage
require("ayu").setup({
  mirage = false, -- Set to `true` to use `mirage` variant instead of `dark` for dark background.
  overrides = {
    Normal = { fg = nil, bg = nil },
    LineNr = { fg = colors.accent },
  }, -- A dictionary of group names, each associated with a dictionary of parameters (`bg`, `fg`, `sp` and `style`) and colors in hex.
})
vim.cmd([[
try
  " colorscheme gruvbox
  " colorscheme tikyonight
  colorscheme ayu
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]])
