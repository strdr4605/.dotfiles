vim.cmd[[ autocmd User Fugitive command! -buffer -bar Graph exe 'terminal' FugitiveShellCommand(['log', '--oneline', '--decorate', '--graph', '--all']) ]]
