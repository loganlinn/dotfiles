#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Hammerspoon - Console
# @raycast.mode silent
# @raycast.icon 🧑‍💻
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

# NB: hs -c cmd for reload produces error b/c connection is interrupted, while stdin is a fire-and-forget.
echo "hs.toggleConsole()" | hs -q
