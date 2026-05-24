#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title btop
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Process filter", "optional": true }
# @raycast.packageName System

# Documentation:
# @raycast.author loganlinn
# @raycast.authorURL https://github.com/loganlinn

panel_opts=(
  --layer=top
  --edge=center-sized
  --columns=1280px
  --lines=1024px
  --focus-policy=on-demand
  --grab-keyboard
  --hide-on-focus-loss
  --toggle-visibility
  --single-instance
  --instance-group=btop
  -o single_window_margin_width=2
  -o single_window_padding_width=2
  -o window_border_width=2
  -o hide_window_decorations=titlebar-and-corners
  -o draw_window_borders_for_single_window=yes
  # -o active_border_color='#00ff00'
)

btop_args=()
[[ -z $1 ]] || btop_args+=( --filter "$1" )

kitten panel "${panel_opts[@]}" btop "${btop_args[@]}"
