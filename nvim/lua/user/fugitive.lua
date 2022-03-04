vim.cmd[[ autocmd User Fugitive command! -buffer -bar Gmylog exe 'terminal' FugitiveShellCommand(['log', '--oneline', '--decorate', '--graph', '--all']) ]]
