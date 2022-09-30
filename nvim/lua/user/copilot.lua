vim.g.copilot_no_tab_map = true
--[[ vim.keymap.set("i", "<C-c>", "copilot#Accept(\"\\<CR>\")<CR>", { silent = true }) ]]
vim.cmd([[ imap <silent><script><expr> <C-J> copilot#Accept("\<CR>") ]])
