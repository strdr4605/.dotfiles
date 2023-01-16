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

return require("packer").startup(function(use)
  -- Packer can manage itself
  use("wbthomason/packer.nvim")
  use("nvim-lua/plenary.nvim") -- Useful lua functions used ny lots of plugins
  use("nvim-tree/nvim-web-devicons")
  use("Pocco81/auto-save.nvim")
  use("ibhagwan/fzf-lua")
  use({ "junegunn/fzf", { run = "./install --all --no-bash --no-fish" } })
  use("ThePrimeagen/harpoon")
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    requires = {
      "windwp/nvim-ts-autotag",
      "JoosepAlviste/nvim-ts-context-commentstring",
      "nvim-treesitter/nvim-treesitter-context",
    },
  })
  use({
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        -- nvim-treesitter/nvim-treesitter-context
        pre_hook = require(
          "ts_context_commentstring.integrations.comment_nvim"
        ).create_pre_hook(),
      })
    end,
  })
  use("tpope/vim-fugitive")
  use("tpope/vim-unimpaired")
  use("tpope/vim-surround")
  use("lewis6991/gitsigns.nvim")
  use({
    "junegunn/gv.vim",
    config = function()
      vim.cmd(
        [[ command! Graph execute 'GV --exclude=refs/remotes/origin/gh-pages --all' ]]
      )
    end,
  })
  -- lsp
  use({
    "neovim/nvim-lspconfig",
    requires = {
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
      "jay-babu/mason-null-ls.nvim",
    },
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
  use("goolord/alpha-nvim")
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "WhoIsSethDaniel/lualine-lsp-progress.nvim" },
  })
  use({
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup({
        show_current_context = true,
        show_current_context_start = false,
      })
    end,
  })
  use("tamago324/lir.nvim")
  use("kevinhwang91/nvim-bqf")
  -- Highlight cursor-word like an IDE.
  use("nyngwang/murmur.lua")
  use("norcalli/nvim-colorizer.lua")

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
    end,
  })

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
