vim.api.nvim_set_keymap("i", "<C-e>", "copilot#Accept('\\<CR>')", { script = true, silent = true, expr = true })
vim.g.copilot_no_tab_map = true
