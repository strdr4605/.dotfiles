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
	use({ "junegunn/fzf", { run = "./install --all --no-bash --no-fish" }})
	use({ "nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" }})

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
