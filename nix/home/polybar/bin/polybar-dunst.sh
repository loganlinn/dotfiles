#!/usr/bin/env bash

set -e

while :; do
    echo -n '%{A1:dunstctl set-paused toggle:}' # left click
    echo -n '%{A2:dunstctl close-all:}'         # middle click
    echo -n '%{A3:dunstctl context:}'           # right click
    echo -n '%{A4:dunstctl close:}'             # scroll up
    echo -n '%{A5:dunstctl history-pop:}'       # scroll down
    if [[ $(dunstctl is-paused) == "true" ]]; then
        [[ -z $PAUSED_BG ]] || echo -n "%{B$PAUSED_BG}"
        [[ -z $PAUSED_FG ]] || echo -n "%{F$PAUSED_FG}"
        echo -n "  "
        waiting=$(dunstctl count waiting)
        if [[ $waiting -gt 0 ]]; then
            [[ -z $ICON_FONT ]] || echo -n "%{T$ICON_FONT}"
            echo -n "󰂠"
            [[ -z $ICON_FONT ]] || echo -n "%{T-}"
            echo -n " ($waiting)"
        else
            [[ -z $ICON_FONT ]] || echo -n "%{T$ICON_FONT}"
            echo -n "󰪓"
            [[ -z $ICON_FONT ]] || echo -n "%{T-}"
        fi
        echo -n "  "
        [[ -z $PAUSED_FG ]] || echo -n "%{F-}"
        [[ -z $PAUSED_BG ]] || echo -n "%{B-}"
    else
        [[ -z $ACTIVE_BG ]] || echo -n "%{B$ACTIVE_BG}"
        [[ -z $ACTIVE_FG ]] || echo -n "%{F$ACTIVE_FG}"
        echo -n "  "
        if [[ $(dunstctl count displayed) -gt 0 ]]; then
            [[ -z $ICON_FONT ]] || echo -n "%{T$ICON_FONT}"
            echo -n "󰵙"
            [[ -z $ICON_FONT ]] || echo -n "%{T-}"
        else
            [[ -z $ICON_FONT ]] || echo -n "%{T$ICON_FONT}"
            echo -n "󰂚"
            [[ -z $ICON_FONT ]] || echo -n "%{T-}"
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
    echo
    if [[ -z $INTERVAL ]]; then
        break
    else
        sleep "$INTERVAL"
    fi
done
