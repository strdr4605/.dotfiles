require("mason").setup()

require("mason-lspconfig").setup({
	ensure_installed = { "jsonls", "sumneko_lua", "tsserver", "cssls" }
})

local lsp_attach = function(_, bufnr)
	local opts = { noremap = true, silent = true }
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
	vim.cmd([[ command! F execute 'lua vim.lsp.buf.format({ async = true })' ]])
end
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require("lspconfig")
require("mason-lspconfig").setup_handlers({
	function(server_name)
		local opts = {
			on_attach = lsp_attach,
			capabilities = lsp_capabilities,
		}

		local has_custom_opts, server_custom_opts = pcall(require, "after.plugin.lsp.server_settings." .. server_name)
		if has_custom_opts then
			opts = vim.tbl_deep_extend("force", opts, server_custom_opts)
		end

		lspconfig[server_name].setup(opts)
	end,
})
