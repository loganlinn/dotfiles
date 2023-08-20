#!/usr/bin/env bash

set -e

fgcolor() {
  printf '%%{F%s}%s%%{F-}' "$1" "$2"
}

icon() {
  if [[ -n $ICON_FONT ]]; then
    echo -n "%{T$ICON_FONT}$*%{T-}"
  else
    echo -n "$*"
  fi
}

render() {
  local paused waiting displayed

  paused=$(dunstctl is-paused)
  waiting=$(dunstctl count waiting)
  displayed=$(dunstctl count displayed)

  echo -n '%{A1:dunstctl set-paused toggle:}' # left click
  echo -n '%{A2:dunstctl close-all:}'         # middle click
  echo -n '%{A3:dunstctl context:}'           # right click
  echo -n '%{A4:dunstctl close:}'             # scroll up
  echo -n '%{A5:dunstctl history-pop:}'       # scroll down
  if [[ $paused == "true" ]]; then
    [[ -z $PAUSED_BG ]] || echo -n "%{B$PAUSED_BG}"
    [[ -z $PAUSED_FG ]] || echo -n "%{F$PAUSED_FG}"
    echo -n "  "
    if ((waiting > 0)); then
      echo -n "$(icon "󰂠") ($waiting)"
    else
      icon "󰪓"
    fi
    echo -n "  "
    [[ -z $PAUSED_FG ]] || echo -n "%{F-}"
    [[ -z $PAUSED_BG ]] || echo -n "%{B-}"
  else
    [[ -z $ACTIVE_BG ]] || echo -n "%{B$ACTIVE_BG}"
    [[ -z $ACTIVE_FG ]] || echo -n "%{F$ACTIVE_FG}"
    echo -n "  "
    if ((displayed > 0)); then
      icon "󰵙"
    else
      icon "󰂚"
    fi
    echo -n "  "
    [[ -z $ACTIVE_FG ]] || echo -n "%{F-}"
    [[ -z $ACTIVE_BG ]] || echo -n "%{B-}"
  fi
  echo -n '%{A}' # left click
  echo -n '%{A}' # middle click
  echo -n '%{A}' # right click
  echo -n '%{A}' # scroll up
  echo -n '%{A}' # scroll down
}

main() {
  while :; do
    render 2>/dev/null ||
      fgcolor "#f00" "    "

    echo # newline required to refresh the module

    if [[ -z $INTERVAL ]]; then
      break
    else
      sleep "$INTERVAL"
    fi
  done
}

main
