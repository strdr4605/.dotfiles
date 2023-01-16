local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>H", function() require("harpoon.ui").toggle_quick_menu() end, opts)
vim.keymap.set("n", "<leader>h", function() require("harpoon.mark").add_file() end, opts)
vim.keymap.set("n", "<leader>j", function() require("harpoon.ui").nav_file(1) end, opts)
vim.keymap.set("n", "<leader>k", function() require("harpoon.ui").nav_file(2) end, opts)
vim.keymap.set("n", "<leader>l", function() require("harpoon.ui").nav_file(3) end, opts)
vim.keymap.set("n", "<leader>;", function() require("harpoon.ui").nav_file(4) end, opts)
