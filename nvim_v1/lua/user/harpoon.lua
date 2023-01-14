local opts = { noremap = true, silent = true }
-- Shorten function name
local keymap = vim.api.nvim_set_keymap

keymap("n", "<leader>H", ":lua require('harpoon.ui').toggle_quick_menu()<CR>", opts)
keymap("n", "<leader>h", ':lua require("harpoon.mark").add_file()<CR>', opts)
keymap("n", "<leader>j", ':lua require("harpoon.ui").nav_file(1)<CR>', opts)
keymap("n", "<leader>k", ':lua require("harpoon.ui").nav_file(2)<CR>', opts)
keymap("n", "<leader>l", ':lua require("harpoon.ui").nav_file(3)<CR>', opts)
keymap("n", "<leader>;", ':lua require("harpoon.ui").nav_file(4)<CR>', opts)
