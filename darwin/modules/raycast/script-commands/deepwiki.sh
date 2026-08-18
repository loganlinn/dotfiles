#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title deepwiki
# @raycast.mode silent
# @raycast.icon 🧑‍💻
# @raycast.argument1 { "type": "text", "placeholder": "repo", "optional": true }

set -e

hash rg

repo="${1-}"
if [[ -z $repo ]]; then
  repo=$(pbpaste)
fi

repo_splug=$(
  rg 'https://github.com/([^/]+)/([^/]+)' \
    --replace '$1/$2' \
    --only-matching \
    <<<"${repo}"
)

open "https://deepwiki.com/${repo_splug}"
