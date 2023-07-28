#!/usr/bin/env bash
# rofi script for polybar commands

menu_option() {
  echo -en "\0${1?}"
  shift
  while (($#)); do
    echo -en "\x1f$1"
    shift
  done
  echo
}

small() { printf "<span weight='light' size='small'>%s</span>" "$*"; }

italic() { printf "<i>%s</i>" "$*"; }

case $ROFI_RETV in
  "")
    mode="$(basename "${0%%.*}")"
    exec rofi -show "$mode" -modes "$mode:$0"
    ;;
  0)
    menu_option prompt "polybar"
    menu_option message ""
    menu_option markup-rows true
    menu_option no-custom true
    menu_option theme "window { location: north; width: 300px; }"
    menu_option theme "inputbar { children: [prompt,entry]; }"
    menu_option theme "element { children: [element-text]; }"

    echo toggle
    echo restart
    echo hide
    echo show
    echo quit
    echo start
    echo stop
    echo kill
    echo enable
    echo disable
    echo cancel
    ;;
  1)
    case $1 in
      quit | hide | show | toggle)
        coproc { polybar-msg cmd "$1" >&2; }
        ;;
      start | stop | restart | enable | disable | kill)
        coproc { systemctl --user "$1" polybar >/dev/null 2>&1; }
        ;;
      cancel)
        exit 0
        ;;
      *)
        exit 1
        ;;
    esac
    ;;
  *)
    echo "unhandled ROFI_RETV: $ROFI_RETV" >&2
    exit 1
    ;;
esac
