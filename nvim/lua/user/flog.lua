vim.cmd(
  [[ command! Graph2 execute 'Flog -format=[%h]\ %d\ {%an}\ %s -- --exclude=refs/remotes/origin/gh-pages --all' ]]
)
