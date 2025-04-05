#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title src-get
# @raycast.mode fullOutput
# @raycast.icon 🧑‍💻
# @raycast.argument1 { "type": "text", "placeholder": "repository" }

# Documentation:
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

export PATH="/etc/profiles/per-user/$USER/bin:$PATH"

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
  "/etc/profiles/per-user/logan/etc/profile.d/hm-session-vars.sh"

case $1 in
# i.e. https://github.com/loganlinn/dotfiles
*://*) repo=$1 ;;
# i.e. git@github.com:loganlinn/dotfiles
*@*:*) repo=$1 ;;
# i.e. github.com/loganlinn/dotfiles
*.*/*) repo="https://$1" ;;
# i.e. loganlinn/dotfiles
*/*) repo="https://github.com/$1" ;;
*)
  echo "Invalid repository reference '$1'" >&2
  exit 1
  ;;
esac

case "$1" in
*@*:*)
  dir="${1#*@}"
  dir=${dir/:/\/}
  ;;
*)
  dir="${1#*://}"
  ;;
esac
dir="${dir%%.git}"
dir=${SRC_HOME:=$HOME/src}/$dir

set -x

if ! [[ -d "$dir" ]]; then
  git clone --depth=1 --progress -- "$repo" "$dir" || exit 1
fi

zoxide add "$dir" || true

open "$dir"
