#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Devin Review
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🧑🏻‍💻
# @raycast.argument1 { "type": "text", "placeholder": "repo", "optional": true }

# Documentation:
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

set -euo pipefail

PATH="$HOME/.dotfiles/bin:$HOME/.local/bin:$PATH"
pr=${1:-}
[[ -n $pr ]] || pr=$(pbpaste)
mise run devin:review:open "$pr"
