#!/usr/bin/env bash

# @example
#   $ gh_latest_release_url stedolan/jq
#   https://github.com/stedolan/jq/releases/tag/jq-1.6
gh_latest_release_url() {
  curl -fsSLI -o /dev/null -w %{url_effective} "https://github.com/${1}/releases/latest" && echo 
}

# @example
#   $ gh_latest_release_url stedolan/jq
#   jq-1.6
gh_latest_release_tag() {
  gh_latest_release_url "$@" | rev | cut -d/ -f1 | rev
}
