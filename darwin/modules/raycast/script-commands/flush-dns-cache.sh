#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Flush DNS Cache
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Developer Utils

# Documentation:
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

set -e
echo "Flushing DNS cache..."
set -x
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
set +x
echo
echo "Done!"
