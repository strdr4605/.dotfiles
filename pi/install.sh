#!/usr/bin/env bash
# Install the pi setup that every machine needs.
# The script is idempotent. Run it as often as you like.

set -euo pipefail

packages=(
  "npm:pi-web-access"
  "git:github.com/DietrichGebert/ponytail"
)

if ! command -v pi >/dev/null; then
  echo "pi is not installed. Install it with: npm install -g @earendil-works/pi-coding-agent"
  exit 1
fi

for package in "${packages[@]}"; do
  echo ">>>> Installing pi package $package"
  pi install "$package"
done

echo ">>>> Refreshing the pi model catalog"
pi update --models || echo "Catalog refresh failed. Run 'pi update --models' later."
