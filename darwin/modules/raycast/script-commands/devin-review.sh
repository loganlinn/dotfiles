#!/usr/bin/env zsh
# @raycast.schemaVersion 1
# @raycast.title deepwiki
# @raycast.mode silent
# @raycast.icon 🧑‍💻
# @raycast.argument1 { "type": "text", "placeholder": "repo", "optional": true }

set -e

hash rg

repo_splug=$(
  rg 'https://github.com/([^/]+)/([^/]+)' \
    --replace '$1/$2' \
    --only-matching \
    <<<"${1?}"
)

open "https://deepwiki.com/${repo_splug}"
