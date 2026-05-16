#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title doom
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 👹
# @raycast.argument1 { "type": "text", "placeholder": "sync", "optional": true }

# Documentation:
# @raycast.description Runs doom emacs command
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${EMACSPATH:=${XDG_CONFIG_HOME}/emacs/}" # expected trailing slash
: "${DOOMPATH:=${XDG_CONFIG_HOME}/doom/}"   # expected trailing slash

export PATH="${EMACSPATH}bin:${DOOMPATH}bin:${PATH}"

# shellcheck disable=2048 disable=2086
doom ${1:-sync}
