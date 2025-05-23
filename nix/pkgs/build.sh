#!/usr/bin/env bash

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_ROOT="${FLAKE_ROOT:-$HERE/../..}"

package=${1?}
shift

exec nix build --impure --print-build-logs --json \
  --arg p "${HERE}/$package" \
  --expr '{ p }: (import (builtins.getFlake (builtins.getEnv "FLAKE_ROOT")).inputs.nixpkgs {}).callPackage p {}' \
  "$@"
