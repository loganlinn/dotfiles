#!/usr/bin/env zsh
# @raycast.schemaVersion 1
# @raycast.title deepwiki.com
# @raycast.mode silent
# @raycast.icon 🧑‍💻
# @raycast.argument1 { "type": "text", "placeholder": "repo", "optional": false }

set -e

hash rg

repo_arg=${1?}

repo_slug=$(
  rg '(github.com/)?([^/]+)/([^/]+)' \
    --replace '$2/$3' \
    --only-matching \
    <<<"${repo_arg?}"
)

: "${DEVIN_BASE_URL:="https://gamma.devinenterprise.com"}"

open "https://deepwiki.com/${repo_slug}"
