require("litee.lib").setup()
require("litee.gh").setup({
  -- the icon set to use from litee.nvim.
  -- "nerd", "codicons", "default"
  icon_set = "nerd",
  -- deprecated, around for compatability for now.
  jump_mode = "invoking",
  -- remap the arrow keys to resize any litee.nvim windows.
  map_resize_keys = false,
  -- by default gh.nvim adds the remote of the pull request's HEAD as an
  -- ssh_url. If you do not have ssh keys configured in GitHub this flag will
  -- use the https clone address instead.
  --
  -- be aware, for gh.nvim to work correctly with private repositories, you
  -- should configure ssh keys and use the default settings. gh.nvim will not
  -- prompt for https authentication.
  prefer_https_remote = false,
  -- do not map any keys inside any gh.nvim buffers.
  disable_keymaps = false,
  -- defines keymaps in gh.nvim buffers.
  keymaps = {
    -- used to open a node in a gh.nvim tree
    open = "<CR>",
    -- expand a node in a gh.nvim tree
    expand = "zo",
    -- collapse the node in a gh.nvim tree
    collapse = "zc",
    -- when cursor is ontop of a '#123' formatted issue reference, open a
    -- new tab with the issue details and comments.
    goto_issue = "gd",
    -- show details associated with a node, for example the commit message
    -- for a commit node in the gh.nvim tree.
    details = "d",
  },
})
