#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title AWS Console
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ☁️
# @raycast.argument1 { "type": "text", "placeholder": "service (e.g. ec2, s3, cw)" }
# @raycast.argument2 { "type": "text", "placeholder": "subcommand (optional)", "optional": true }
# @raycast.packageName AWS

# Documentation:
# @raycast.description Open an AWS Console page for a service or sub-resource
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

set -euo pipefail

service="${1:-}"
subcommand="${2:-}"

exec zsh -lc 'aws-console "$@"' -s ${service:+"$service"} ${subcommand:+"$subcommand"}
