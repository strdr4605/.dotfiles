local lir = require("lir")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.keymap.set(
  "n",
  "-",
  [[<Cmd>execute 'e ' .. expand('%:p:h')<CR>]],
  { noremap = true }
)

local actions = require("lir.actions")
local mark_actions = require("lir.mark.actions")
local clipboard_actions = require("lir.clipboard.actions")

lir.setup({
  show_hidden_files = true,
  devicons = {
    enable = true,
  },
  mappings = {
    ["l"] = actions.edit,
    ["<C-s>"] = actions.split,
    ["<C-v>"] = actions.vsplit,

    ["h"] = actions.up,
    ["q"] = actions.quit,

    ["K"] = actions.mkdir,
    ["N"] = actions.newfile,
    ["R"] = actions.rename,
    ["@"] = actions.cd,
    ["Y"] = actions.yank_path,
    ["."] = actions.toggle_show_hidden,
    ["D"] = actions.delete,

    ["J"] = function()
      mark_actions.toggle_mark()
      vim.cmd("normal! j")
    end,
    ["C"] = clipboard_actions.copy,
    ["X"] = clipboard_actions.cut,
    ["P"] = clipboard_actions.paste,
  },
  hide_cursor = false,
})

-- -- custom folder icon
require("nvim-web-devicons").set_icon({
  lir_folder_icon = {
    icon = "",
    color = "#7ebae4",
    name = "LirFolderNode",
  },
})
