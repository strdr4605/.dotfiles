local status_ok, wk = pcall(require, "which-key")
if not status_ok then
  return
end

wk.register({
  h = {
    name = "+Gitsigns",
    s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage hunk" },
    u = { "<cmd>Gitsigns undo_stage_hunk<cr>", "Undo stage hunk" },
    S = { "<cmd>Gitsigns stage_buffer<cr>", "Stage buffer" },
    r = { "<cmd>Gitsigns reset_hunk<cr>", "Reset hunk" },
    p = { "<cmd>Gitsigns preview_hunk<cr>", "Preview hunk" },
    b = { "<cmd>lua require'gitsigns'.blame_line{full=true}<cr>", "Blame line full" },
  },
  t = {
    name = "+Toggle",
    b = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Current line blame" },
    d = { "<cmd>Gitsigns toggle_deleted<cr>", "Deleted" },
  },
}, { prefix = "<leader>" })
