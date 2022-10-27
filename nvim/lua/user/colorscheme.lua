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
colors.generate(false) -- Pass `true` to enable mirage
require("ayu").setup({
  mirage = false, -- Set to `true` to use `mirage` variant instead of `dark` for dark background.
  overrides = {
    Wildmenu = { bg = colors.bg, fg = colors.markup },
    Comment = { fg = "gray", italic = true },
    LineNr = { fg = "gray" },
  },
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

-- transparent mode
local highlights = {
  "Normal",
  "LineNr",
  "Folded",
  "NonText",
  "SpecialKey",
  "VertSplit",
  "SignColumn",
  "EndOfBuffer",
}
for _, highlight in pairs(highlights) do
  vim.cmd.highlight(highlight .. " guibg=none ctermbg=none")
end
