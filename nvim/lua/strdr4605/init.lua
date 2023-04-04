require("strdr4605.remap")
require("strdr4605.set")
require("strdr4605.better-quickfix")
require("strdr4605.lazy")

-- Project specific settings, not sure if this is the best way to do it, maybe will change later
local local_nvimrc = vim.fn.getcwd()..'/.nvimrc.lua'
if vim.loop.fs_stat(local_nvimrc) then
  vim.cmd('source '..local_nvimrc)
end
