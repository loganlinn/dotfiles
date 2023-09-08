#!/usr/bin/env bash

set -eo pipefail

worktree_main() {
  git worktree list --porcelain | head -n1 | cut -d' ' -f2
}

worktree_cleanup() {
  if [[ -d $WORKTREE_PATH ]] && gum confirm "Remove worktree $(basename "$WORKTREE_PATH")? "; then
    git worktree remove --force "$WORKTREE_PATH"
  fi
}

trap worktree_cleanup EXIT

WORKTREE_REV=$(gum input --header "worktree revision" --value 'main@{upstream}') || exit $?
WORKTREE_COMMIT=$(git rev-parse --verify --short "${WORKTREE_REV?}") || exit $?

: "${WORKTREE_PATH:=$(worktree_main).${WORKTREE_COMMIT?}}"

if [[ -d $WORKTREE_PATH ]]; then
  n=1
  while [[ -d "$WORKTREE_PATH~$n" ]]; do
    n=$((n + 1))
  done
  WORKTREE_PATH="$WORKTREE_PATH~$n"
fi

git worktree add --force --detach "${WORKTREE_PATH?}" "${WORKTREE_COMMIT?}"

: "${WORKTREE_COMMAND:=$(gum input --header "worktree command" --value "${*:-${SHELL-bash}}" || exit $?)}"

env --chdir="${WORKTREE_PATH?}" "${WORKTREE_COMMAND?}"
