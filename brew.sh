#!/bin/bash
echo ">>>> Installing Homebrew"
if test ! "$(which brew)"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi
brew update
echo ">>>> Install Homebrew Packages"
brew bundle
brew cleanup

echo ">>>> Installing ComicCode Font"
FONT_DIR="$HOME/Library/Fonts"

# Check if Comic Code fonts already exist
if ls "$FONT_DIR"/ComicCodeNerdFont* >/dev/null 2>&1 || ls "$FONT_DIR"/*ComicCode* >/dev/null 2>&1; then
  echo "Comic Code fonts already installed, skipping."
else
  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"' EXIT

  gh repo clone strdr4605/ComicCode "$TEMP_DIR" -- --depth 1 --quiet 2>/dev/null || {
    echo "Warning: Could not clone ComicCode repo. Skipping font installation."
    exit 0
  }

  # Install Comic Code Nerd Font
  NERD_FONT_PATH="$TEMP_DIR/Tabular Type Foundry/Comic Code Nerd Font"
  if [ -d "$NERD_FONT_PATH" ]; then
    find "$NERD_FONT_PATH" -name "*.ttf" -o -name "*.otf" | while read -r font; do
      cp "$font" "$FONT_DIR/" && echo "Installed: $(basename "$font")"
    done
    echo "Comic Code Nerd Font installed!"
  else
    echo "Comic Code Nerd Font not found in repo"
  fi
fi
