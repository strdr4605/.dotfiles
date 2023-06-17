-- Remaps
local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("", "<Space>", "<Nop>", opts)

-- Keeping it centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<ESC><ESC>", ":nohlsearch<CR><ESC>", opts)
vim.keymap.set("n", "<S-c>", ":windo lcl|ccl<CR>", opts)

-- Using christoomey/vim-tmux-navigator to navigate between tmux panes and vim splits
-- Better window navigation
-- vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
-- vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
-- vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
-- vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

vim.keymap.set("n", "<leader>a", "<cmd>%y+<cr>", opts)
vim.keymap.set("n", "<leader>d", '"_d', opts)
vim.keymap.set("n", "<leader>cc", '"_c', opts)
vim.keymap.set("n", "x", '"_x', opts)
vim.keymap.set("v", "p", '"_dP', opts)
vim.keymap.set("v", "<leader>d", '"_d', opts)
vim.keymap.set("v", "<leader>c", '"_c', opts)

-- prevent accidental case changes when wanting to yank
vim.keymap.set("v", "u", "<Nop>", opts)

-- Undo break points
vim.keymap.set("i", ",", ",<C-g>u", opts)
vim.keymap.set("i", ".", ".<C-g>u", opts)
vim.keymap.set("i", "!", "!<C-g>u", opts)
vim.keymap.set("i", "?", "?<C-g>u", opts)

-- Move text up and down
vim.keymap.set("v", "J", ":move '>+1<CR>gv-gv", opts)
vim.keymap.set("v", "K", ":move '<-2<CR>gv-gv", opts)

-- Settings
vim.opt.wrap = false

-- https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/set.lua
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.clipboard = "unnamedplus"               -- allows neovim to access the system clipboard
vim.opt.cmdheight = 1                           -- more space in the neovim command line for displaying messages
vim.opt.completeopt = { "menuone", "noselect" } -- mostly just for cmp
vim.opt.conceallevel = 0                        -- so that `` is visible in markdown files
vim.opt.fileencoding = "utf-8"                  -- the encoding written to a file
vim.opt.hlsearch = true                         -- highlight all matches on previous search pattern
vim.opt.ignorecase = true                       -- ignore case in search patterns
vim.opt.mouse = "a"                             -- allow the mouse to be used in neovim
vim.opt.pumheight = 20                          -- pop up menu height
vim.opt.showmode = false                        -- we don't need to see things like -- INSERT -- anymore
vim.opt.showtabline = 0                         -- always show tabs
vim.opt.smartcase = true                        -- smart case
vim.opt.smartindent = true                      -- make indenting smarter again
vim.opt.splitbelow = true                       -- force all horizontal splits to go below current window
vim.opt.splitright = true                       -- force all vertical splits to go to the right of current window
vim.opt.termguicolors = true                    -- set term gui colors (most terminals support this)
vim.opt.timeoutlen = 1000                       -- time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.expandtab = true                        -- convert tabs to spaces
vim.opt.shiftwidth = 2                          -- the number of spaces inserted for each indentation
vim.opt.tabstop = 2                             -- insert 2 spaces for a tab
vim.opt.cursorline = true                       -- highlight the current line
vim.opt.number = true                           -- set numbered lines
vim.opt.relativenumber = true                   -- set relative numbered line
vim.opt.laststatus = 3                          -- only the last window will always have a status line
vim.opt.showcmd = false                         -- hide (partial) command in the last line of the screen (for performance)
vim.opt.ruler = false                           -- hide the line and column number of the cursor position
vim.opt.numberwidth = 2                         -- minimal number of columns to use for the line number {default 4}
vim.opt.scrolloff = 8                           -- minimal number of screen lines to keep above and below the cursor
-- vim.opt.sidescrolloff = 8 -- minimal number of screen columns to keep to the left and right of the cursor if wrap is `false`
vim.opt.guifont = "monospace:h17"               -- the font used in graphical neovim applications
-- vim.opt.fillchars.eob = " " -- show empty lines at the end of a buffer as ` ` {default `~`}
-- vim.opt.shortmess:append("c") -- hide all the completion messages, e.g. "-- XXX completion (YYY)", "match 1 of 2", "The only match", "Pattern not found"
vim.opt.whichwrap:append("<,>,[,],h,l")                                                                                                            -- keys allowed to move to the previous/next line when the beginning/end of line is reached
vim.opt.iskeyword:append("-")                                                                                                                      -- treats words with `-` as single words
vim.opt.guicursor =
"n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"   -- setting for guicursor taken from :h 'guicursor'

local augroup = vim.api.nvim_create_augroup("strdr4605", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  pattern = "*",
  group = augroup,
  command = "setlocal cursorline",
})
vim.api.nvim_create_autocmd("WinLeave", {
  pattern = "*",
  group = augroup,
  command = "setlocal nocursorline",
})
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  group = augroup,
  command = "LuaSnipUnlinkCurrent",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typescript,typescriptreact",
  group = augroup,
  command = "compiler tsc | setlocal makeprg=npx\\ tsc",
})
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*eslint*",
  group = augroup,
  command = "compiler eslint | setlocal makeprg=npm\\ run\\ eslint:run\\ --\\ --format\\ compact",
})
vim.api.nvim_create_autocmd("TextYankPost ", {
  pattern = "*",
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  group = augroup,
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- Better quickfix
local fn = vim.fn

function _G.qftf(info)
  local items
  local ret = {}
  if info.quickfix == 1 then
    items = fn.getqflist({ id = info.id, items = 0 }).items
  else
    items = fn.getloclist(info.winid, { id = info.id, items = 0 }).items
  end
  local limit = 51
  local fnameFmt1, fnameFmt2 =
      "%-" .. limit .. "s", "...%." .. (limit - 1) .. "s"
  local validFmt = "%s |%5d:%-3d|%s %s"
  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local fname = ""
    local str
    if e.valid == 1 then
      if e.bufnr > 0 then
        fname = fn.bufname(e.bufnr)
        if fname == "" then
          fname = "[No Name]"
        else
          fname = fname:gsub("^" .. vim.env.HOME, "~")
        end
        -- char in fname may occur more than 1 width, ignore this issue in order to keep performance
        if #fname <= limit then
          fname = fnameFmt1:format(fname)
        else
          fname = fnameFmt2:format(fname:sub(1 - limit))
        end
      end
      local lnum = e.lnum > 99999 and -1 or e.lnum
      local col = e.col > 999 and -1 or e.col
      local qtype = e.type == "" and "" or " " .. e.type:sub(1, 1):upper()
      str = validFmt:format(fname, lnum, col, qtype, e.text)
    else
      str = e.text
    end
    table.insert(ret, str)
  end
  return ret
end

vim.o.qftf = "{info -> v:lua._G.qftf(info)}"

-- Plugins
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

require("lazy").setup({
  "nvim-lua/plenary.nvim", -- Useful lua functions used ny lots of plugins
  "nvim-tree/nvim-web-devicons",
  -- "Pocco81/auto-save.nvim",
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
      "hrsh7th/cmp-buffer",       -- buffer completions
      "hrsh7th/cmp-path",         -- path completions
      "hrsh7th/cmp-cmdline",      -- cmdline completions
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
