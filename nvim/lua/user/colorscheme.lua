-- gruvbox
vim.g.gruvbox_bold = 0
vim.opt.termguicolors = true
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[
try
  colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]])
