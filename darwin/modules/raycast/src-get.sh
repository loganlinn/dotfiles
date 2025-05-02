#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title src-get
# @raycast.mode silent
# @raycast.icon 🧑‍💻
# @raycast.argument1 { "type": "text", "placeholder": "repository" }

# Documentation:
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

#shellcheck disable=SC1090
source-if-exists() {
  local arg
  for arg; do
    if [[ -f "$arg" ]]; then
      source "$arg"
    fi
  done
}

export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH"

source-if-exists \
  "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" \
  "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"

if PANE_ID=$(wezterm cli spawn); then
  wezterm cli send-text --pane-id "$PANE_ID" --no-paste "src-get $(printf %q "$1")"$'\n'
fi
