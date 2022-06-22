local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don"t error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- My plugins here
  use "wbthomason/packer.nvim" -- Have packer manage itself
  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
  use { "numToStr/Comment.nvim", config = require("user.comment") }
  use { "Pocco81/AutoSave.nvim", config = require("user.autosave") }
  use "moll/vim-bbye"
  use "tpope/vim-unimpaired"
  use { "goolord/alpha-nvim", config = require("user.alpha-nvim") }
  use { "norcalli/nvim-colorizer.lua", config = require("user.colorized") }
  use { "nvim-lualine/lualine.nvim", config = require("user.lualine") }
  use "rescript-lang/vim-rescript"
  use { "lukas-reineke/indent-blankline.nvim", config = require("user.indent-blankline") }
  use { "ibhagwan/fzf-lua", config = require("user.fzf-lua") }
  use { "junegunn/fzf", run = './install --all --no-bash --no-fish', }
  use "airblade/vim-rooter"
  use { "folke/which-key.nvim", config = require("user.which-key") }
  use { "tamago324/lir.nvim", config = require("user.lir") }
  use {
    "ptzz/lf.vim",
    requires = {
      "voldikss/vim-floaterm"
    },
    config = require("user.lf")
  }
  use { "kyazdani42/nvim-web-devicons" }
  use { "kevinhwang91/nvim-bqf" }

  -- Themes
  use "ellisonleao/gruvbox.nvim"

  -- cmp plugins
  use { "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-buffer", -- buffer completions
      "hrsh7th/cmp-path", -- path completions
      "hrsh7th/cmp-cmdline", -- cmdline completions
      "hrsh7th/cmp-emoji",
      "saadparwaiz1/cmp_luasnip", -- snippet completions
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",

      -- snippets
      "L3MON4D3/LuaSnip", -- snippet engine
      "rafamadriz/friendly-snippets", -- a bunch of snippets to use
    },
    config = require("user.cmp")
  } -- The completion plugin

  -- LSP
  use { "neovim/nvim-lspconfig", -- enable LSP
    requires = {
      "williamboman/nvim-lsp-installer", -- simple to use language server installer
      "jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
    },
    config = require("user.lsp")
  }
  use { "j-hui/fidget.nvim", config = require("user.fidget") }

  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    requires = {
      "p00f/nvim-ts-rainbow",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = require("user.treesitter")
  }

  -- Git
  use { "lewis6991/gitsigns.nvim", config = require("user.gitsigns") }
  use "tpope/vim-fugitive"
  use { "rbong/vim-flog", config = require("user.flog") }
  use {
    "ldelossa/gh.nvim",
    requires = {
      "ldelossa/litee.nvim"
    },
    config = require("user.gh")
  }
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
