-- This file can be loaded by calling `lua require("plugins")` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	use({
		"ibhagwan/fzf-lua",
		-- optional for icon support
		requires = { "nvim-tree/nvim-web-devicons" }
	})
	use({ "junegunn/fzf", { run = "./install --all --no-bash --no-fish" } })
	use({ "nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" } })
	use("tpope/vim-fugitive")
	-- lsp
	use({
		"neovim/nvim-lspconfig",
		requires = {
			"williamboman/mason-lspconfig.nvim",
			"williamboman/mason.nvim",
		}
	})
	-- cmp
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-buffer", -- buffer completions
			"hrsh7th/cmp-path", -- path completions
			"hrsh7th/cmp-cmdline", -- cmdline completions
			"saadparwaiz1/cmp_luasnip", -- snippet completions
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",

			-- snippets
			"L3MON4D3/LuaSnip", -- snippet engine
		},
	})

	-- Colorscheme
	use({
		"ellisonleao/gruvbox.nvim",
		config = function()
			vim.cmd("colorscheme gruvbox")
			vim.opt.background = "light"
			require("gruvbox").setup({
				contrast = "hard", -- can be "hard", "soft" or empty string
				transparent_mode = true,
			})
		end
	})
end)
