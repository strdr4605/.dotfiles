local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("", "<Space>", "<Nop>", opts)

-- Keeping it centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<ESC><ESC>", ":nohlsearch<CR><ESC>", opts)
vim.keymap.set("n", "<S-c>", ":windo lcl|ccl<CR>", opts)

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

vim.keymap.set("n", "<leader>a", "<cmd>%y+<cr>", opts)
vim.keymap.set("n", "<leader>d", '"_d', opts)
vim.keymap.set("n", "<leader>c", '"_c', opts)
vim.keymap.set("n", "x", '"_x', opts)
vim.keymap.set("v", "p", '"_dP', opts)
vim.keymap.set("v", "<leader>d", '"_d', opts)
vim.keymap.set("v", "<leader>c", '"_c', opts)

-- Undo break points
vim.keymap.set("i", ",", ",<C-g>u", opts)
vim.keymap.set("i", ".", ".<C-g>u", opts)
vim.keymap.set("i", "!", "!<C-g>u", opts)
vim.keymap.set("i", "?", "?<C-g>u", opts)

-- Move text up and down
vim.keymap.set("v", "J", ":move '>+1<CR>gv-gv", opts)
vim.keymap.set("v", "K", ":move '<-2<CR>gv-gv", opts)
