local fzf_lua = require("fzf-lua")

vim.keymap.set("n", "<leader>f", ":lua require('fzf-lua').git_files()<CR>", opts)
vim.keymap.set("n", "<leader><S-f>", ":lua require('fzf-lua').live_grep_native()<CR>", opts)
vim.keymap.set("n", "<leader>r", ":lua require('fzf-lua').resume()<CR>", opts)
vim.keymap.set("n", "<leader>b", ":lua require('fzf-lua').buffers()<CR>", opts)

fzf_lua.setup({
  -- fzf_bin = "/Users/strdr4605/.local/share/nvim/site/pack/packer/start/fzf/bin/fzf",
  fzf_opts = {
    ["--layout"] = "reverse",
    -- ["--ansi"] = false,
  },
  keymap = {
    fzf = {
      ["ctrl-w"] = "select-all+accept",
    },
  },
  grep = {
    -- rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=512",
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
