#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title src-get
# @raycast.mode silent
# @raycast.icon 🧑‍💻
# @raycast.argument1 { "type": "text", "placeholder": "rep (optional)", "optional": true }

# Documentation:
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

set -e

export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH"

#shellcheck disable=SC1090
source-if-exists() {
  local arg
  for arg; do
    if [[ -f "$arg" ]]; then
      source "$arg"
    fi
  done
}

source-if-exists \
  "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" \
  "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"

if [[ -z "$repo" ]]; then
  repo=$(pbpaste)
fi

NL=$'\n'

wezterm cli send-text --pane-id "$(wezterm cli spawn)" --no-paste "$(printf 'src-get %q' "$repo")$NL"
