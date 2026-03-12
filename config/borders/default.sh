#!/bin/bash
# Default borders profile - edit without rebuilding nix
# Colors passed from bordersrc, other options defined here
#
# Run directly to update running borders:
#   ~/.config/borders/default.sh [color_overrides...]
#
# Options: style, width, hidpi, ax_focus, blacklist, whitelist
# See `man borders` for documentation

options=(
  style=round
  width=6.0
  hidpi=on
)

borders "${options[@]}" "$@"
