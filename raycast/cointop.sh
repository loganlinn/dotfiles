#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title cointop
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🪙
# @raycast.packageName crypto

# Documentation:
# @raycast.author Logan Linn
# @raycast.authorURL https://github.com/loganlinn

/Applications/Alacritty.app/Contents/MacOS/alacritty --title cointop --command $HOME/go/bin/cointop
