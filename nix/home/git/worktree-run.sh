#!/usr/bin/env bash
# worktree-run.sh: start temporary worktree shell

set -eo pipefail

if ! command -v gum 2>/dev/null; then
  gum() { nix run nixpkgs#gum -- "$@"; }
fi

# TODO args for these
rev=$(gum input --header "Revision" --value 'main@{upstream}')
commit=$(git rev-parse --verify --short "${rev?}")
main_worktree_path=$(git worktree list --porcelain | head -n1 | cut -d' ' -f2)
worktree_path=${main_worktree_path?}.${commit?}

# get a unique name
if [[ -d $worktree_path ]]; then
  worktree_path="$worktree_path~$RANDOM"
fi

cleanup() {
  if [[ -d $worktree_path ]] && gum confirm "Remove worktree $(basename "$worktree_path")? "; then
    git worktree remove --force "$worktree_path"
  fi
}
trap cleanup EXIT

git worktree add --force --detach "${worktree_path?}" "${commit?}"

# shellcheck disable=2046
env --chdir="${worktree_path?}" - $(gum input --header "worktree command" --value "${*:-${SHELL-bash}}")
