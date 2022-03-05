vim.cmd[[ autocmd User Fugitive command! -buffer -bar Graph exe 'terminal' FugitiveShellCommand(['log', '--oneline', '--decorate', '--graph', '--exclude=refs/remotes/origin/gh-pages', '--all']) ]]
