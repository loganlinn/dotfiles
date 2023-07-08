venv-select() {
  # prints path to venv directory given path argument(s), defaulting to the working directory.
  # if multiple venvs exist, shows interactive selection menu.
  if fd --search-path "${1:-$PWD}" \
    --unrestricted pyvenv.cfg \
    --prune \
    --exec echo "{//}" |
    fzf --select-1 \
      --exit-0 \
      --header "select python venv" \
      --preview '{}/bin/pip list --disable-pip-version-check --no-python-version-warning'; then
    return 0
  elif [[ $? == 130 ]]; then # fzf interrupted with CTRL-C or ESC
    return 130
  else
    echo "no venv found in ${*:-$PWD}" >&2
    return 1
  fi
}

venv-activate() {
  local env_dir
  if env_dir=$(venv-select "$@"); then
    # shellcheck disable=1091
    source "$env_dir/bin/activate" &&
      echo "✅ activated: $env_dir"
  fi
}

venv() {
  # wrapper for python3's built-in venv module.
  # * sets default options:
  #     --upgrade-deps
  #
  # * adds additional options:
  #   --[no-]activate
  #   --no-upgrade-deps
  local activate=true
  local upgrade_deps=true
  local args_out=()
  local arg_in

  for arg_in; do
    case $arg_in in
      --activate) activate=true ;;
      --no-activate) activate= ;;
      --no-upgrade-deps) upgrade_deps= ;;
      *) args_out+=("$arg_in") ;;
    esac
  done

  # add --upgrade-deps arg, which was added python 3.9
  if [[ $upgrade_deps == true ]] && python3 -c 'import sys; sys.version_info >= (3, 9) or sys.exit(1)'; then
    args_out=(--upgrade-deps "${args_out[@]}")
  fi

  python3 -m venv "${args_out[@]}" || return $?

  local env_dir="${args_out[-1]}"
  if [[ $activate == true ]] && [[ -d $env_dir ]]; then
    venv-activate "$env_dir"
  fi
}
