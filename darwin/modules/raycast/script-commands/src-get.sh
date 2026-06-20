#!/usr/bin/env zsh
# @raycast.schemaVersion 1
# @raycast.title src-get
# @raycast.mode silent
# @raycast.icon 🧑‍💻
# @raycast.argument1 { "type": "text", "placeholder": "repo", "optional": false }

# Documentation:
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

set -e

source "$HOME/.dotfiles/bin/src-get"

src-get "$1"

pwd | pbcopy
