#!/usr/bin/env bash

rofi_log() {
  printf "%b\n" "$*" >&2
}

rofi_menu_option() {
  log "setting $1=$(printf "'%s' " "${@:2}")"
  # pass mode/row options
  echo -en "\0${1?}"
  shift
  while (($#)); do
    echo -en "\x1f$1"
    shift
  done
  echo
}

rofi_menu_row() {
  printf '%b' "$1"
  shift
  if (($#)); then rofi_menu_option "$@"; fi
  echo # menu_delim=$'\n'
}
