local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don"t error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

-- Install your plugins here
return packer.startup(function(use)
  -- My plugins here
  use("wbthomason/packer.nvim") -- Have packer manage itself
  use("nvim-lua/popup.nvim") -- An implementation of the Popup API from vim in Neovim
  use("nvim-lua/plenary.nvim") -- Useful lua functions used ny lots of plugins
  use({ "numToStr/Comment.nvim", config = function() require("user.comment") end })
  use({ "Pocco81/auto-save.nvim", config = function() require("user.auto-save") end })
  use("moll/vim-bbye")
  use("tpope/vim-unimpaired")
  use({ "goolord/alpha-nvim", config = function() require("user.alpha-nvim") end })
  use({ "norcalli/nvim-colorizer.lua", config = function() require("user.colorizer") end })
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "WhoIsSethDaniel/lualine-lsp-progress.nvim" },
    config = function() require("user.lualine") end,
  })
  use("rescript-lang/vim-rescript")
  use({ "lukas-reineke/indent-blankline.nvim", config = function() require("user.indent-blankline") end })
  use({ "ibhagwan/fzf-lua", config = function() require("user.fzf-lua") end })
  use({ "junegunn/fzf", run = "./install --all --no-bash --no-fish" })
  use({ "tamago324/lir.nvim", config = function() require("user.lir") end })
  use({
    "ptzz/lf.vim",
    requires = {
      "voldikss/vim-floaterm",
    },
    config = function() require("user.lf") end,
  })
  use({ "kyazdani42/nvim-web-devicons" })
  use({ "kevinhwang91/nvim-bqf" })
  use({ "https://github.com/github/copilot.vim", config = function() require("user.copilot") end })
  use({ "ja-ford/delaytrain.nvim", config = function() require("user.delaytrain") end })
  use({ "folke/lua-dev.nvim" })
  -- use({
  --   "folke/noice.nvim",
  --   config = function() require("user.noice") end,
  --   requires = {
  --     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
  --     "MunifTanjim/nui.nvim",
  --     -- OPTIONAL:
  --     --   `nvim-notify` is only needed, if you want to use the notification view.
  --     --   If not available, we use `mini` as the fallback
  --     "rcarriga/nvim-notify",
  --   }
  -- })
  -- Themes
  use("ellisonleao/gruvbox.nvim")

  -- cmp plugins
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
      "rafamadriz/friendly-snippets", -- a bunch of snippets to use
    },
    config = function() require("user.cmp") end,
  }) -- The completion plugin

  -- LSP
  use({
    "neovim/nvim-lspconfig",
    requires = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
      "jose-elias-alvarez/typescript.nvim",
    },
    config = function() require("user.lsp") end,
  })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    requires = {
      "p00f/nvim-ts-rainbow",
      "windwp/nvim-ts-autotag",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function() require("user.treesitter") end,
  })
  use({ "nvim-treesitter/nvim-treesitter-context" })

  -- Git
  use({ "lewis6991/gitsigns.nvim", config = function() require("user.gitsigns") end })
  use("tpope/vim-fugitive")
  use({ "rbong/vim-flog", config = function() require("user.flog") end })
  use({ "junegunn/gv.vim", config = function() require("user.gv") end })
  use({ "sindrets/diffview.nvim" })

  use({ "wesleimp/stylua.nvim" })
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
