BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ">>>> Installing Homebrew"
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew update
echo ">>>> Install Homebrew Packages"
brew tap homebrew/bundle
brew bundle

echo ">>>> Linking opensdk-11"
sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk

echo ">>>> Installing Oh My Zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
./npmi.sh

echo ">>>> Force linking ${BASEDIR}/nvim to ~/.config/nvim\n\n"
rm -rf ~/.config/nvim
ln -sf ${BASEDIR}/nvim ~/.config/nvim 

curl https://raw.githubusercontent.com/strdr4605/tt/latest/tt.sh > ~/tt.sh

dotfiles=(
    .zshrc
    .gitconfig
    .tmux.conf
)
for file in "${dotfiles[@]}"; do
  echo ">>>> Force linking ${BASEDIR}/${file} to ~/${file}"
  ln -sf ${BASEDIR}/${file} ~/${file}
done

echo "\n>>>> Please run ./iterm2.sh after opening iTerm2"
