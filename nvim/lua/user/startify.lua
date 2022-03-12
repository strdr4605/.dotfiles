vim.cmd[[ autocmd User StartifyBufferOpened Gcd ]]
-- https://textkool.com/en/test-ascii-art-generator?text=strdr4605
vim.g.startify_custom_header = {
  "        _           _        ___   ____ _____ _____ ",
  "       | |         | |      /   | / ___|  _  |  ___|",
  "    ___| |_ _ __ __| |_ __ / /| |/ /___| |/' |___ \\ ",
  "   / __| __| '__/ _` | '__/ /_| || ___ \\  /| |   \\ \\",
  "   \\__ \\ |_| | | (_| | |  \\___  || \\_/ \\ |_/ /\\__/ /",
  "   |___/\\__|_|  \\__,_|_|      |_/\\_____/\\___/\\____/ ",
}
vim.g.startify_lists = {
  { type = 'dir', header = { '   Current Directory ' .. vim.fn.getcwd() } },
  { type = 'sessions', header = { '   Sessions' } },
  { type = 'files', header = { '   Most Recently Used' } },
}
vim.g.startify_session_persistence = 1
