function kitty-user-vars {
  (($#)) || set -- --self
  kitty @ ls "$@" | jq '.[].tabs[].windows[0].user_vars'
}


alias kls='kitty-ls'
alias klS='kitty-ls-self'
alias kitty-ls='kitty @ ls ${KITTY_LS_DEFAULT_OPTS:---all-env-vars}'
alias kitty-ls-self='kitty-ls --self'

: "${KITTY_JQ_DEFAULT_COMMAND:=command kitty @ ls --all-env-vars}"
: "${KITTY_JQ_DEFAULT_OPTS:=}"

export KITTY_JQ_DEFAULT_COMMAND KITTY_JQ_DEFAULT_OPTS

function kitty-jq-tabs {
  emulate -L zsh

  local filter="${*:-.}"
  local -a jq_opts=()
  [[ -n ${KITTY_JQ_DEFAULT_OPTS-} ]] &&
    jq_opts=( "${(@Q)${(z)KITTY_JQ_DEFAULT_OPTS}}" )

  "${SHELL:-zsh}" -c "${KITTY_JQ_DEFAULT_COMMAND:?}" |
    command jq "${jq_opts[@]}" ".[].tabs[] | $filter"
}

function kitty-jq-windows {
  emulate -L zsh

  local filter="${*:-.}"
  local -a jq_opts=()
  [[ -n ${KITTY_JQ_DEFAULT_OPTS-} ]] &&
    jq_opts=( "${(@Q)${(z)KITTY_JQ_DEFAULT_OPTS}}" )

  "${SHELL:-zsh}" -c "${KITTY_JQ_DEFAULT_COMMAND:?}" |
    command jq "${jq_opts[@]}" ".[].tabs[] | .id as \$tab_id | .windows[] | .tab_id = \$tab_id | $filter"
}

alias kitty-jq-tabs='noglob kitty-jq-tabs'
alias kitty-jq-windows='noglob kitty-jq-windows'

function kitty-rg-text {
  emulate -L zsh
  setopt pipefail

  local -a kitty_args get_text_args rg_args

  while (( $# )); do
    case $1 in
      --extent=*)
        get_text_args+=( "$1" )
        shift
        ;;
      --extent)
        get_text_args+=( "$1" )
        [[ $# -ge 2 && $2 != -* ]] && { get_text_args+=( "$2" ); shift 2; } || shift
        ;;
      --to=*|--password=*|--password-file=*|--password-env=*|--use-password=*)
        kitty_args+=( "$1" )
        shift
        ;;
      --to|--password|--password-file|--password-env|--use-password)
        kitty_args+=( "$1" )
        [[ $# -ge 2 && $2 != -* ]] && { kitty_args+=( "$2" ); shift 2; } || shift
        ;;
      --)
        shift
        rg_args+=( "$@" )
        break
        ;;
      *)
        rg_args+=( "$1" )
        shift
        ;;
    esac
  done

  (( $#rg_args )) || {
    print -ru2 -- "usage: kitty-rg-text [kitty args] [--] <rg args>"
    return 2
  }

  local tmp
  tmp=$(command mktemp -d "${TMPDIR:-/tmp}/kitty-rg-text.XXXXXXXX") || return

  {
    local win id rel file

    while IFS= read -r win; do
      id=$(command jq -r .id <<< "$win") || return
      rel=$(command jq -r .path <<< "$win") || return
      file="$tmp/$rel"

      command mkdir -p -- "${file:h}"
      command kitty @ "${kitty_args[@]}" get-text "${get_text_args[@]}" --match "id:$id" >| "$file" || return
    done < <(
      command kitty @ "${kitty_args[@]}" ls --all-env-vars |
        command jq -c '
          def clean:
            gsub("[^A-Za-z0-9._-]+"; "_") |
            gsub("^_+|_+$"; "") |
            if . == "" then "untitled" else . end;

          .[].tabs[] | .id as $tab_id | .windows[] |
          {
            id,
            path: ("tab_\($tab_id)/win_\(.id)__\(((.title // "untitled") | clean)).txt")
          }
        '
    )

    ( CDPATH= builtin cd "$tmp" && rg "${rg_args[@]}" )
    return
  } always {
    command rm -rf -- "$tmp"
  }
}

alias kitty-rg-text='noglob kitty-rg-text'
