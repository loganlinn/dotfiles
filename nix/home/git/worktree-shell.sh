#!/usr/bin/env bash
# worktree-run.sh: start temporary worktree shell
set -e
set -o pipefail

if ! command -v gum 2>/dev/null; then
  hash nix
  gum() { nix run "nixpkgs#gum" -- "$@"; }
fi

# TODO args for these
rev=$(gum input --header "Worktree commit" --value 'main@{upstream}')
commit=$(git rev-parse --verify --short "${rev?}")
main_worktree_path=$(git worktree list --porcelain | head -n1 | cut -d' ' -f2)

i=0
worktree_path=${main_worktree_path?}.${commit?}
while [[ -d $worktree_path ]]; do
  worktree_path="${main_worktree_path?}.${commit?}.${i}"
  i=$((i + 1))
fi
unset i
worktree_path=$(gum input --header "Worktree path" --value "$worktree_path")

cleanup() {
  if [[ -d $worktree_path ]] && gum confirm "Remove worktree, $(basename "$worktree_path")? "; then
    git worktree remove --force "$worktree_path"
  fi
}
trap cleanup EXIT

git worktree add --force --detach "${worktree_path?}" "${commit?}"

# shellcheck disable=2046
env --chdir="${worktree_path?}" - $(gum input --header "worktree command" --value "${*:-${SHELL-bash}}")
