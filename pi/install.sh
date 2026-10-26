#!/usr/bin/env bash
# Install the pi setup that every machine needs.
# The script is idempotent. Run it as often as you like.

set -euo pipefail

packages=(
  "npm:pi-web-access"
  "git:github.com/DietrichGebert/ponytail"
  "npm:surf-cli"
)

if ! command -v pi >/dev/null; then
  echo "pi is not installed. Install it with: npm install -g @earendil-works/pi-coding-agent"
  exit 1
fi

for package in "${packages[@]}"; do
  echo ">>>> Installing pi package $package"
  pi install "$package"
done

if ! command -v surf >/dev/null; then
  echo ">>>> Installing the surf CLI"
  npm install -g surf-cli
fi

echo ">>>> Refreshing the pi model catalog"
pi update --models || echo "Catalog refresh failed. Run 'pi update --models' later."

echo ">>>> Next: run ./pi/surf-host.sh to connect surf to the browser"
