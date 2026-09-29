#!/bin/bash
# Open a URL in the desktop template's Chrome without taking a screenshot.
# Usage: bash open-browser.sh <url>
set -eu
export DISPLAY=":0"
URL="${1:?Usage: bash open-browser.sh <url>}"
PROFILE="/home/user/.chrome-sandbox-profile"
mkdir -p "$PROFILE"
setsid nohup google-chrome \
  --no-first-run --no-default-browser-check \
  --disable-features=TranslateUI \
  --user-data-dir="$PROFILE" \
  --new-window "$URL" >/home/user/chrome-sandbox.log 2>&1 < /dev/null &
sleep 5
echo "Chrome launch requested for: $URL"
pgrep -a -f 'google-chrome' || true
