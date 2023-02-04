#! /usr/bin/env nix-shell
#! nix-shell -i bash -p hacksaw i3

# i3 + hacksaw
#
# float active window to area drawn with mouse

set -e

hacksaw -n | {
    IFS=+x read -r w h x y

    w=$((w + w % 2))
    h=$((h + h % 2))

    i3-msg -q floating enable
    i3-msg -q resize set width "$w" px height "$h" px
    i3-msg -q move position "$x" px "$y" px
}
