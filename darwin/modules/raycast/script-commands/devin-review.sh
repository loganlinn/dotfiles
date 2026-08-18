#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Devin Review
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🧑🏻‍💻
# @raycast.argument1 { "type": "text", "placeholder": "repo", "optional": true }

# Documentation:
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

PATH="$HOME/.dotfiles/bin:$HOME/.local/bin:$PATH"
mise run devin:review:open "$1"
