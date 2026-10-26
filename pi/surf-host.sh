#!/usr/bin/env bash
# Connect the surf CLI to the local browser.
# The script is idempotent. Run it as often as you like.
#
# The extension id changes per machine and per user. The script asks for it.

set -euo pipefail

if ! command -v surf >/dev/null; then
  echo "surf is not installed. Install it with: npm install -g surf-cli"
  exit 1
fi

extension_path="$(surf extension-path)"

echo ">>>> Load the surf extension in your browser"
echo "     1. Open brave://extensions or chrome://extensions"
echo "     2. Enable Developer mode"
echo "     3. Click Load unpacked and paste this path:"
echo "        $extension_path"
echo

read -r -p ">>>> Extension id from the extension card: " extension_id

if [ -z "$extension_id" ]; then
  echo "No extension id given. Stopping."
  exit 1
fi

# Brave reads the Chrome native messaging directory. The Chrome manifest serves both browsers.
surf install "$extension_id" --browser chrome
surf install "$extension_id" --browser brave

echo ">>>> Check the connection with: surf doctor --browser chrome"
echo ">>>> Restart the browser, then check with: surf tab.list"
