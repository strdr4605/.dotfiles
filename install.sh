BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Homebrew"
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew update
echo "Install Homebrew Packages"
brew tap homebrew/bundle
brew bundle

echo "Installing Oh My Zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Force linking ${BASEDIR}/nvim to ~/.config/nvim"
ln -sf ${BASEDIR}/nvim ~/.config/nvim 

dotfiles=(
    .zshrc
    .gitconfig
)
for file in "${dotfiles[@]}"; do
  echo "Force linking ${BASEDIR}/${file} to ~/${file}"
  ln -sf ${BASEDIR}/${file} ~/${file}
done

