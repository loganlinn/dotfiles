#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Notes (Kitty)
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📓
# @raycast.argument1 { "type": "text", "placeholder": "command (e.g. claude)", "optional": true }

# Documentation:
# @raycast.description Open a Kitty window in ~/Notes, optionally running a command
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

set -euo pipefail

export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/opt/homebrew/bin:$PATH"

if [[ -n "${1:-}" ]]; then
    kitty --single-instance --directory "$HOME/Notes" -- "$1"
else
    kitty --single-instance --directory "$HOME/Notes"
fi
