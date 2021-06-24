#!/usr/bin/env zsh

export DOCKER_SCAN_SUGGEST=false
export NEXT_TELEMETRY_DISABLED=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_BUNDLE_FILE=$(dirname "$0:A")/../../tag-darwin/Brewfile
export GEM_HOME=$HOME/.gem
