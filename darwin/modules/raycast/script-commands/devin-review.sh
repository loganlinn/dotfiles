#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Devin Review
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "PR ref (URL, #123, branch, LIN-123)", "optional": true }
# @raycast.packageName Devin

# Documentation:
# @raycast.description Open a pull request in Devin's review UI
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

set -euo pipefail

ref="${1:-}"
if [[ -z "$ref" ]]; then
  clip="$(pbpaste 2>/dev/null || true)"
  if [[ "$clip" =~ ^https?://(github\.com|app\.devin\.ai)/ ]] ||
    [[ "$clip" =~ ^[A-Z]{2,}-[0-9]+$ ]] ||
    [[ "$clip" =~ ^#?[0-9]+$ ]]; then
    ref="$clip"
  fi
fi

exec zsh -lc 'devin-review "$@"' -s "${ref:+"$ref"}"
