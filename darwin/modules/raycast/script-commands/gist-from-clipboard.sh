#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Gist from Clipboard
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐙
# @raycast.argument1 { "type": "text", "placeholder": "filename (optional)", "optional": true }
# @raycast.packageName GitHub

# Documentation:
# @raycast.description Create a GitHub gist from clipboard contents and open it in the browser
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

set -euo pipefail

export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH"

filename="${1:-clipboard.txt}"

content=$(pbpaste)
if [[ -z "$content" ]]; then
  echo >&2 "Clipboard is empty"
  exit 1
fi

url=$(gh gist create -f "$filename" - <<<"$content")

if [[ -n "$url" ]]; then
  printf '%s' "$url" | pbcopy
  open "$url"
  echo "Created: $url"
else
  echo >&2 "Failed to create gist"
  exit 1
fi
