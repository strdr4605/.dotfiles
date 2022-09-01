local status_ok, fzf_lua = pcall(require, "fzf-lua")
if not status_ok then
  return
end

fzf_lua.setup({
  -- fzf_bin = "/Users/strdr4605/.local/share/nvim/site/pack/packer/start/fzf/bin/fzf",
  fzf_opts = {
    ["--layout"] = "default",
    -- ["--ansi"] = false,
  },
  keymap = {
    fzf = {
      ["ctrl-w"] = "select-all+accept",
    }
  },
  grep = {
    -- rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=512",
    file_icons = false,
    git_icons = false,
  },
  winopts = {
    split = "belowright new",
    preview = {
      hidden = "hidden",
      default = "bat_native",
      horizontal = "right:40%",
    },
  },
})

vim.cmd("FzfLua register_ui_select")
