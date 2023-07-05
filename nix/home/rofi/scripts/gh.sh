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
  gh_pr_opts+=(--repo "$REPOSITORY")
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

menu_option() {
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
  if (($#)); then menu_option "$@"; fi
  echo # menu_delim=$'\n'
}

menu_action() {
  local content=$1
  shift
  menu_row "$content" info "RUN $*"
  # NB: handled by menu_entry_selected
}

gh_pr_view_menu() {
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

  menu_option prompt "PR"
  menu_option message "$message"
  menu_option markup-rows true
  menu_option no-custom true
  menu_option use-hot-keys true
  # menu_option keep-selection
  # menu_option new-selection
  # menu_option data
  menu_option theme "window { width: calc(75px + ${width}ch); }"
  menu_option theme "element { children: [element-text]; }"

  local pr_number
  for row in "${rows[@]}"; do
    log "row:" "$row"
    pr_number="$(cut -d' ' -f1 <<<"$row")"
    # NOTE: quoted expansion requires bash 4.4
    menu_action "$row" "gh ${gh_opts[*]@Q} pr ${gh_pr_opts[*]@Q} view ${gh_pr_view_opts[*]@Q} '$pr_number'"
  done
}

# menu_confirm() {
#   menu_action Confirm "$1"
#   menu_action Cancel ""
# }

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

  gh_pr_view_menu
}

menu_entry_selected() {
  log handling: entry selected

  case ${ROFI_INFO?} in
    "CALL "*)
      log "calling: ${ROFI_INFO#CALL }"
      eval "${ROFI_INFO#CALL }"
      ;;
    "RUN "*)
      log "evaluating: ${ROFI_INFO#RUN } >&2"
      eval "${ROFI_INFO#RUN } >&2"
      ;;
    # "CONFIRM "*)
    #   menu_confirm "${ROFI_INFO#CONFIRM }"
    #   ;;
    *)
      log "unexpected ROFI_INFO"
      exit 1
      ;;
  esac
}

menu_custom_entry_selected() {
  log handling: custom entry selected

}

menu_custom_keybind_pressed() {
  log handling: hot-key pressed: "-kb-custom-$1"
}

### execute

log "$0: BEGIN

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

log "$0: END\n"
exit 0
