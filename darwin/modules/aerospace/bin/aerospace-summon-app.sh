#!/usr/bin/env bash

set -euo pipefail

summon_app_windows() {
  local app_bundle_id=${1?}
  local workspace=${2-}
  local app_window_ids

  if [[ -z $workspace ]]; then
    workspace=$(aerospace list-workspaces --focused)
  fi

  app_window_ids=$(aerospace list-windows --app-bundle-id "$app_bundle_id" --monitor all --json | jq -rc '.[].["window-id"]')
  if [[ -z $app_window_ids ]]; then
    echo >&2 "$app_bundle_id: no windows found."
    return 1
  fi

  for window_id in $app_window_ids; do
    echo >&2 "$app_bundle_id: summoning window: $window_id"

    # when window already on target workspace, but not visible,
    # we use 'open -b' as fallback (using --fail-if-noop)
    aerospace move-node-to-workspace \
      --window-id "$window_id" \
      --focus-follows-window \
      --fail-if-noop \
      "$workspace" ||
      open -b "$app_bundle_id"
  done
}

if [[ $# -eq 0 ]]; then
  echo >&2 "usage: $(basename "${BASH_SOURCE[0]}") app-bundle-id..."
  exit 1
fi

for app_bundle_id in "$@"; do
  if ! summon_app_windows "$app_bundle_id"; then
    echo >&2 "$app_bundle_id: opening..."
    open -b "$app_bundle_id"
  fi
done
