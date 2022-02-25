#!/usr/bin/env bash

# ZSH and OMZ
brew install zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

brew install neovim

# FiraCode - https://github.com/tonsky/FiraCode/wiki/Installing#macos
brew tap homebrew/cask-fonts
brew install --cask font-fira-code

# iTerm
brew install --cask iterm2
open /Applications/iTerm.app
echo -e "\n------------------------ Please run ./iterm2.sh"
