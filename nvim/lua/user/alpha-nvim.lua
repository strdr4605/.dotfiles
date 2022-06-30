local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
  return
end

local startify = require("alpha.themes.startify")

local header = {
  type = "text",
  val = {
    "        _           _        ___   ____ _____ _____ ",
    "       | |         | |      /   | / ___|  _  |  ___|",
    "    ___| |_ _ __ __| |_ __ / /| |/ /___| |/' |___ \\ ",
    "   / __| __| '__/ _` | '__/ /_| || ___ \\  /| |   \\ \\",
    "   \\__ \\ |_| | | (_| | |  \\___  || \\_/ \\ |_/ /\\__/ /",
    "   |___/\\__|_|  \\__,_|_|      |_/\\_____/\\___/\\____/ ",
  },
  opts = {
    hl = "Type",
    shrink_margin = false,
    -- wrap = "overflow";
  },
}

startify.config.layout = {
  { type = "padding", val = 1 },
  header,
  { type = "padding", val = 2 },
  startify.section.top_buttons,
  startify.section.mru,
  startify.section.mru_cwd,
  { type = "padding", val = 1 },
  startify.section.bottom_buttons,
  startify.section.footer,
}

alpha.setup(startify.config)
