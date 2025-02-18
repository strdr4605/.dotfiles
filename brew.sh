echo ">>>> Installing Homebrew"
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi
brew update
echo ">>>> Install Homebrew Packages"
brew tap homebrew/bundle
brew bundle
brew cleanup
