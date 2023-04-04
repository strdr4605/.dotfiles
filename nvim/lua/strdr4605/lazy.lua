local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

return require("lazy").setup({
  "nvim-lua/plenary.nvim", -- Useful lua functions used ny lots of plugins
  "nvim-tree/nvim-web-devicons",
  "Pocco81/auto-save.nvim",
  "christoomey/vim-tmux-navigator",
  {
    "ibhagwan/fzf-lua",
    config = function()
      require("strdr4605.plugins.fzf-lua")
    end,
  },
  { "junegunn/fzf", build = "./install --all --no-bash --no-fish" },
  {
    "ThePrimeagen/harpoon",
    config = function()
      require("strdr4605.plugins.harpoon")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("strdr4605.plugins.treesitter")
    end,
    dependencies = {
      "windwp/nvim-ts-autotag",
      "JoosepAlviste/nvim-ts-context-commentstring",
      "nvim-treesitter/nvim-treesitter-context",
    },
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        -- nvim-treesitter/nvim-treesitter-context
        pre_hook = require(
          "ts_context_commentstring.integrations.comment_nvim"
        ).create_pre_hook(),
      })
    end,
  },
  "tpope/vim-dispatch",
  "tpope/vim-fugitive",
  "tpope/vim-unimpaired",
  "tpope/vim-surround",
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("strdr4605.plugins.gitsigns")
    end,
  },
  {
    "junegunn/gv.vim",
    config = function()
      vim.cmd(
        [[ command! Graph execute 'GV --exclude=refs/remotes/origin/gh-pages --all' ]]
      )
    end,
  },
  -- lsp
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("strdr4605.plugins.lsp")
    end,
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
      "jay-babu/mason-null-ls.nvim",
      "jose-elias-alvarez/typescript.nvim",
    },
  },
  -- cmp
  {
    "hrsh7th/nvim-cmp",
    config = function()
      require("strdr4605.plugins.nvim-cmp")
    end,
    dependencies = {
      "hrsh7th/cmp-buffer", -- buffer completions
      "hrsh7th/cmp-path", -- path completions
      "hrsh7th/cmp-cmdline", -- cmdline completions
      "saadparwaiz1/cmp_luasnip", -- snippet completions
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",

      -- snippets
      "L3MON4D3/LuaSnip", -- snippet engine
    },
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("strdr4605.plugins.copilot")
    end,
  },
  {
    "goolord/alpha-nvim",
    config = function()
      require("strdr4605.plugins.alpha")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("strdr4605.plugins.lualine")
    end,
    dependencies = {
      "WhoIsSethDaniel/lualine-lsp-progress.nvim",
      "f-person/git-blame.nvim",
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup({
        show_current_context = true,
        show_current_context_start = false,
      })
    end,
  },
  {
    "tamago324/lir.nvim",
    config = function()
      require("strdr4605.plugins.lir")
    end,
  },
  "kevinhwang91/nvim-bqf",
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("strdr4605.plugins.colorizer")
    end,
  },
  {
    "moll/vim-bbye",
    config = function()
      require("strdr4605.plugins.vim-bbye")
    end,
  },

  -- Colorscheme
  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      -- vim.cmd("colorscheme gruvbox")
      vim.opt.background = "light"
      require("gruvbox").setup({
        contrast = "hard", -- can be "hard", "soft" or empty string
        transparent_mode = true,
      })
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    config = function()
      vim.cmd("colorscheme kanagawa")
      vim.opt.background = "light"
    end,
  },
})
