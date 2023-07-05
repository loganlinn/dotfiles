#!/usr/bin/env bash

set -e

### script dependencies
hash rofi gh || exit 127

IFS=" " read -r -a rofi_opts <<<"$ROFI_OPTS"
IFS=" " read -r -a gh_opts <<<"$GH_OPTS"
IFS=" " read -r -a gh_pr_opts <<<"$GH_PR_OPTS"
IFS=" " read -r -a gh_pr_list_opts <<<"$GH_PR_LIST_OPTS"
IFS=" " read -r -a gh_pr_view_opts <<<"$GH_PR_VIEW_OPTS"

if [[ -n $REPOSITORY ]]; then
  gh_pr_opts+=(-R "$REPOSITORY")
fi

gh_pr_list_opts+=(
  --limit "${GH_PR_LIST_LIMIT-100}"
  --state "${GH_PR_LIST_STATE-open}"
)

gh_pr_view_opts+=(--web)

### helpers

log() {
  printf "%b\n" "$*" >&2
}

menu_set() {
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

menu_row() {
  printf '%b' "$1"
  shift
  if (($#)); then menu_set "$@"; fi
  echo # menu_delim=$'\n'
}

### state handlers

menu_exec() {
  log handling: menu execution
  local mode
  mode="$(basename "${0%%.*}")"
  exec rofi "${rofi_opts[@]}" \
    -show "$mode" \
    -modes "$mode:$0"
}

menu_init() {
  log handling: menu initialization

  local row rows message width

  rows=()
  unset REPLY
  while read -r; do
    if [[ -z $message ]]; then
      message=$REPLY
    else
      width=$((width < ${#REPLY} ? ${#REPLY} : width))
      rows+=("$REPLY")
    fi
  done < <(
    gh "${gh_opts[@]}" \
      pr "${gh_pr_opts[@]}" \
      list "${gh_pr_list_opts[@]}" \
      --json "number,title,author,state" \
      --template '{{tablerow "NUMBER" "TITLE" "AUTHOR" "STATE"}}{{range .}}{{tablerow (printf "#%v" .number) (truncate 55 .title) .author.login .state}}{{end}}'
  )

  menu_set prompt "󰊤  PR"
  menu_set message "$message"
  menu_set markup-rows true
  menu_set no-custom true
  # menu_set keep-selection
  # menu_set new-selection
  # menu_set data
  menu_set theme "window { width: calc(75px + ${width}ch); }"
  menu_set theme "element { children: [element-text]; }"

  for row in "${rows[@]}"; do
    log "row:" "$row"
    menu_row "$row" info "$(cut -d' ' -f1 <<<"$row")"
  done
}

menu_entry_selected() {
  log handling: entry selected

  local pr_number="${ROFI_INFO?}"

  log "launching 'gh ${gh_opts[*]} pr ${gh_pr_opts[*]} view ${gh_pr_view_opts[*]} $pr_number'"
  coproc {
    gh "${gh_opts[@]}" pr "${gh_pr_opts[@]}" view "${gh_pr_view_opts[@]}" "$pr_number"
  }
}

menu_custom_entry_selected() {
  log handling: custom entry selected

}

menu_custom_keybind_pressed() {
  log handling: custom keybind
}

### execute

log "$0: started

ENVIRONMENT:
$(printenv | grep '^ROFI_' | sed 's/^/    /')
$(printenv | grep '^GH_' | sed 's/^/    /')

ARGUMENTS: $(printf "'%s'" "$@")
"

case "${ROFI_RETV-}" in
  "")
    menu_exec "$@"
    ;;
  0)
    menu_init "$@"
    ;;
  1)
    menu_entry_selected "$@"
    ;;
  2)
    menu_custom_entry_selected "$@"
    ;;
  1[0-9] | 2[0-8])
    menu_custom_keybind_pressed $((ROFI_RETV + 1 - 10))
    ;;
  *)
    log "unhandled state: $ROFI_RETV"
    exit 1
    ;;
esac

log "$0: complete"
exit 0
