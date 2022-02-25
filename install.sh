BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dotfiles=(
    .zshrc
    .gitconfig
)
for file in "${dotfiles[@]}"; do
  echo "Force linking ${BASEDIR}/${file} to ~/${file}"
  ln -sf ${BASEDIR}/${file} ~/${file}
done

./brew.sh
