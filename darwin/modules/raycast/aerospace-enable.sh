#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Aerospace - Toggle Enabled
# @raycast.mode inline
# @raycast.refreshTime 1h

# Optional parameters:
# @raycast.icon 🛸

# Documentation:
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

aerospace enable toggle

# NB: most aerospace commands fail when not enabled; this is just one of them.
if aerospace config --config-path &>/dev/null; then
  echo "Enabled"
  /usr/bin/logger -is -t aerospace "enabled via raycast script: ${BASH_SOURCE[0]} $*" || true
else
  echo "Disabled"
  /usr/bin/logger -is -t aerospace "disabled via raycast script: ${BASH_SOURCE[0]} $*" || true
fi
