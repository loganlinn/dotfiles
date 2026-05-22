#!/usr/bin/env zsh
# aws-console - open or print AWS Console URLs.
# Mirrors AWS CLI service names as subcommands.
#
# Usage: aws-console <service> [<subcommand>] [--print|--url]
#
# Region is taken from AWS_DEFAULT_REGION or AWS_REGION (default: us-east-2).

emulate -L zsh
setopt extended_glob warn_create_global typeset_silent no_short_loops \
  rc_quotes no_auto_pushd pipefail err_return

typeset -gr AWS_CONSOLE_SCRIPT="${0:t}"
typeset -gr AWS_CONSOLE_DIR="${0:A:h}"
typeset -gr AWS_CONSOLE_DEFAULT_CONFIG="${AWS_CONSOLE_DIR}/aws-console.ini"

typeset -ga AWS_CONSOLE_SERVICE_ORDER
typeset -gA AWS_CONSOLE_ALIAS_OF
typeset -gA AWS_CONSOLE_ALIASES_BY_TARGET
typeset -gA AWS_CONSOLE_BASE
typeset -gA AWS_CONSOLE_FIELD_ORDER
typeset -gA AWS_CONSOLE_INI
typeset -gA AWS_CONSOLE_PATH
typeset -gA AWS_CONSOLE_SUBCOMMANDS

read-ini-file() {
  emulate -L zsh
  setopt extended_glob warn_create_global typeset_silent no_short_loops \
    rc_quotes no_auto_pushd pipefail err_return

  local ini_file=$1 out_hash=$2 key_prefix=${3:-}
  local line section="void" access_string
  integer line_no=0
  local -a match mbegin mend

  if [[ ! -r $ini_file ]]; then
    print -ru2 -- "${AWS_CONSOLE_SCRIPT}: config not readable: $ini_file"
    return 1
  fi

  while IFS= read -r line || [[ -n $line ]]; do
    (( ++line_no ))

    if [[ $line = [[:blank:]]#(\;|\#)* || $line = [[:blank:]]# ]]; then
      continue
    elif [[ $line = (#b)[[:blank:]]#\[([^\]]##)\][[:blank:]]# ]]; then
      section=$match[1]
      AWS_CONSOLE_SERVICE_ORDER+=( "$section" )
    elif [[ $line = (#b)[[:blank:]]#([^[:blank:]=]##)[[:blank:]]#[=][[:blank:]]#(*) ]]; then
      match[2]="${match[2]%"${match[2]##*[! $'\t']}"}"
      access_string="${out_hash}[${key_prefix}<${section}>_${match[1]}]"
      : "${(P)access_string::=${match[2]}}"
      AWS_CONSOLE_FIELD_ORDER[$section]="${AWS_CONSOLE_FIELD_ORDER[$section]:+${AWS_CONSOLE_FIELD_ORDER[$section]} }${match[1]}"
    else
      print -ru2 -- "${AWS_CONSOLE_SCRIPT}: expected section or key=value in $ini_file:$line_no"
      return 1
    fi
  done < "$ini_file"
}

load_config() {
  emulate -L zsh
  setopt extended_glob warn_create_global typeset_silent no_short_loops \
    rc_quotes no_auto_pushd pipefail err_return

  local config=$1 section field value ini_key
  local -a fields

  AWS_CONSOLE_SERVICE_ORDER=()
  AWS_CONSOLE_ALIAS_OF=()
  AWS_CONSOLE_ALIASES_BY_TARGET=()
  AWS_CONSOLE_BASE=()
  AWS_CONSOLE_FIELD_ORDER=()
  AWS_CONSOLE_INI=()
  AWS_CONSOLE_PATH=()
  AWS_CONSOLE_SUBCOMMANDS=()

  read-ini-file "$config" AWS_CONSOLE_INI

  for section in "${AWS_CONSOLE_SERVICE_ORDER[@]}"; do
    fields=( ${=AWS_CONSOLE_FIELD_ORDER[$section]} )
    for field in "${fields[@]}"; do
      ini_key="<${section}>_${field}"
      value=$AWS_CONSOLE_INI[$ini_key]

      case $field in
      _alias_of)
        AWS_CONSOLE_ALIAS_OF[$section]=$value
        AWS_CONSOLE_ALIASES_BY_TARGET[$value]="${AWS_CONSOLE_ALIASES_BY_TARGET[$value]:+${AWS_CONSOLE_ALIASES_BY_TARGET[$value]} }$section"
        ;;
      _base)
        AWS_CONSOLE_BASE[$section]=$value
        ;;
      _default)
        AWS_CONSOLE_PATH[$section/]=$value
        ;;
      _*)
        print -ru2 -- "${AWS_CONSOLE_SCRIPT}: unknown directive '$field' in section: $section"
        return 1
        ;;
      *)
        AWS_CONSOLE_PATH[$section/$field]=$value
        AWS_CONSOLE_SUBCOMMANDS[$section]="${AWS_CONSOLE_SUBCOMMANDS[$section]:+${AWS_CONSOLE_SUBCOMMANDS[$section]} }$field"
        ;;
      esac
    done
  done
}

usage() {
  emulate -L zsh
  setopt extended_glob warn_create_global typeset_silent no_short_loops \
    rc_quotes no_auto_pushd pipefail err_return

  local exit_status=${1:-1}
  local service aliases_text name subcommands_text
  local -a aliases subcommands

  print -ru2 -- "Usage: ${AWS_CONSOLE_SCRIPT} <service> [<subcommand>] [--print|--url]"
  print -ru2 -- ""
  print -ru2 -- "Open (or print) the AWS Console page for a service or sub-resource."
  print -ru2 -- ""
  print -ru2 -- "Services and subcommands:"

  for service in "${AWS_CONSOLE_SERVICE_ORDER[@]}"; do
    (( ${+AWS_CONSOLE_ALIAS_OF[$service]} )) && continue

    aliases=( ${=AWS_CONSOLE_ALIASES_BY_TARGET[$service]} )
    aliases_text=""
    if (( ${#aliases} )); then
      aliases_text=" (${(j:, :)aliases})"
    fi
    name="${service}${aliases_text}"

    subcommands=( ${=AWS_CONSOLE_SUBCOMMANDS[$service]} )
    subcommands_text="${(j:, :)subcommands}"

    if (( ${#subcommands} )); then
      print -u2 -f "  %-24s %s\n" "$name" "$subcommands_text"
    else
      print -ru2 -- "  $name"
    fi
  done

  print -ru2 -- ""
  print -ru2 -- "Options:"
  print -ru2 -- "  --print, --url   Print the URL to stdout instead of opening it"
  print -ru2 -- "  -h, --help       Show this help"
  print -ru2 -- ""
  print -ru2 -- "Environment:"
  print -ru2 -- "  AWS_DEFAULT_REGION   Region to use (default: us-east-2)"
  print -ru2 -- "  AWS_REGION           Fallback if AWS_DEFAULT_REGION is unset"
  print -ru2 -- "  AWS_CONSOLE_CONFIG   Config file (default: ${AWS_CONSOLE_DEFAULT_CONFIG})"

  return "$exit_status"
}

open_url() {
  emulate -L zsh
  setopt extended_glob warn_create_global typeset_silent no_short_loops \
    rc_quotes no_auto_pushd pipefail err_return

  local url=$1 opener
  local -a openers=( open /usr/bin/open xdg-open )

  for opener in "${openers[@]}"; do
    if [[ $opener == */* ]]; then
      [[ -x $opener ]] || continue
      "$opener" "$url"
      return
    elif (( $+commands[$opener] )); then
      command "$opener" "$url"
      return
    fi
  done

  print -ru2 -- "No browser opener found (tried: ${(j:, :)openers}). URL:"
  print -r -- "$url"
}

main() {
  emulate -L zsh
  setopt extended_glob warn_create_global typeset_silent no_short_loops \
    rc_quotes no_auto_pushd pipefail err_return

  local region="${AWS_DEFAULT_REGION:-${AWS_REGION:-us-east-2}}"
  local config="${AWS_CONSOLE_CONFIG:-$AWS_CONSOLE_DEFAULT_CONFIG}"
  local regional_base="https://${region}.console.aws.amazon.com"
  local global_base="https://us-east-1.console.aws.amazon.com"
  local service="" subcommand="" action="open" arg
  local requested_service path_key path base_kind base_url url
  local -a known_subcommands

  load_config "$config"

  for arg in "$@"; do
    case $arg in
      --print | --url)
        action=print
        ;;
      -h | --help)
        usage 0
        return 0
        ;;
      -*)
        print -ru2 -- "Unknown flag: $arg"
        usage 1
        ;;
      *)
        if [[ -z $service ]]; then
          service=$arg
        elif [[ -z $subcommand ]]; then
          subcommand=$arg
        else
          print -ru2 -- "Unexpected argument: $arg"
          usage 1
        fi
        ;;
    esac
  done

  [[ -n $service ]] || usage 1

  requested_service=$service
  if (( ${+AWS_CONSOLE_ALIAS_OF[$service]} )); then
    service=$AWS_CONSOLE_ALIAS_OF[$service]
  fi

  if (( ! ${+AWS_CONSOLE_BASE[$service]} )); then
    print -ru2 -- "Unknown service: $requested_service"
    usage 1
  fi

  path_key="${service}/${subcommand}"
  if (( ! ${+AWS_CONSOLE_PATH[$path_key]} )); then
    if [[ -z $subcommand ]]; then
      print -ru2 -- "${AWS_CONSOLE_SCRIPT}: missing default URL for service: $service"
    else
      print -ru2 -- "Unknown subcommand: ${requested_service} ${subcommand}"
      known_subcommands=( ${=AWS_CONSOLE_SUBCOMMANDS[$service]} )
      if (( ${#known_subcommands} )); then
        print -ru2 -- "Known subcommands: ${(j:, :)known_subcommands}"
      fi
    fi
    return 1
  fi

  base_kind=$AWS_CONSOLE_BASE[$service]
  case $base_kind in
    regional)
      base_url=$regional_base
      ;;
    global)
      base_url=$global_base
      ;;
    http://* | https://*)
      base_url=$base_kind
      ;;
    *)
      print -ru2 -- "${AWS_CONSOLE_SCRIPT}: unknown base '$base_kind' for service: $service"
      return 1
      ;;
  esac

  path=$AWS_CONSOLE_PATH[$path_key]
  path=${path//\$\{REGION\}/$region}
  url="${base_url}${path}"

  case $action in
    print)
      print -r -- "$url"
      ;;
    open)
      open_url "$url"
      ;;
  esac
}

main "$@"
