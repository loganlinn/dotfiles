#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title GitHub PR Approve
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🚢
# @raycast.argument1 { "type": "text", "placeholder": "URL | owner∕repo#123" }
# @raycast.packageName GitHub
# @raycast.needsConfirmation true

# Documentation:
# @raycast.description Approve a GitHub pull request (LGTM, rubberstamp, shipit)
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <https://github.com/OWNER/REPO/pull/NUMBER | OWNER/REPO#NUMBER>" >&2
  exit 2
fi

pull_request=$1

if [[ $pull_request =~ ^(https://)?github\.com/([^/]+)/([^/]+)/pull/([1-9][0-9]*)(/?([?#].*)?)?$ ]]; then
  gh pr review --approve "$pull_request"
elif [[ $pull_request =~ ^([^/#[:space:]]+)/([^/#[:space:]]+)#([1-9][0-9]*)$ ]]; then
  repository=${BASH_REMATCH[1]}/${BASH_REMATCH[2]}
  pull_request_number=${BASH_REMATCH[3]}
  gh pr review --approve "$pull_request_number" -R "$repository"
else
  echo "Invalid input. Use a GitHub PR URL or OWNER/REPO#NUMBER." >&2
  exit 2
fi
