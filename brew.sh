echo ">>>> Installing Homebrew"
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew update
echo ">>>> Install Homebrew Packages"
brew tap homebrew/bundle
brew bundle
