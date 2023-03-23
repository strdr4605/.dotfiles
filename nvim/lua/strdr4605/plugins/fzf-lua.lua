local fzf_lua = require("fzf-lua")

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>f", function()
  require("fzf-lua").git_files()
end, opts)
vim.keymap.set("n", "<leader><S-f>", function()
  require("fzf-lua").live_grep_glob()
end, opts)
vim.keymap.set("n", "<leader>r", function()
  require("fzf-lua").resume()
end, opts)
vim.keymap.set("n", "<leader>b", function()
  require("fzf-lua").buffers()
end, opts)

fzf_lua.setup({
  actions = {
    buffers = {
      ["default"] = fzf_lua.actions.buf_edit,
      ["ctrl-d"] = function(selected, opts) 
        fzf_lua.actions.buf_del(selected, opts)
        fzf_lua.buffers()
      end,
    },
  },
  fzf_opts = {
    ["--layout"] = "reverse",
    -- ["--ansi"] = false,
  },
  keymap = {
    fzf = {
      ["ctrl-q"] = "select-all+accept",
    },
  },
  grep = {
    rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case --max-columns=512",
    file_icons = false,
    git_icons = false,
  },
  winopts = {
    --[[ split = "belowright new", ]]
    preview = {
      hidden = "nohidden",
      default = "bat",
      horizontal = "bottom:40%",
    },
  },
  previewers = {
    bat = {
      cmd = "bat",
      args = "--style=numbers,changes --color always",
      theme = "gruvbox-light", -- bat preview theme (bat --list-themes)
      config = nil, -- nil uses $BAT_CONFIG_PATH
    },
  },
})

vim.cmd("FzfLua register_ui_select")
