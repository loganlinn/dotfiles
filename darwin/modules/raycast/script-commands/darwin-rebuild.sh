#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title darwin-rebuild
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon ❄️
# @raycast.argument1 { "type": "text", "placeholder": "default: switch", "optional": true }

# Documentation:
# @raycast.author llinn
# @raycast.authorURL https://raycast.com/llinn

# shellcheck disable=SC2086
exec /run/current-system/sw/bin/darwin-rebuild ${1:-switch}
