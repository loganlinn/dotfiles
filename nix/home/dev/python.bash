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
  # adds additional options:
  #     --[no-]activate

  local activate=true
  local params arg

  # use --upgrade-deps by default if python >= 3.9
  # shellcheck disable=2207
  params=($(python -c 'import sys; sys.version_info >= (3, 9) and print("--upgrade-deps")'))

  # Build up params from input args.
  # Allow auto-activation and modified defaults to be negated.
  for arg; do
    case $arg in
      --activate) activate=true ;;
      --no-activate) activate=false ;;
      --no-upgrade-deps) params=("${params[@]/--upgrade-deps/}") ;;
      *) params+=("$arg") ;;
    esac
  done

  if ! python3 -m venv "${params[@]}"; then
    return $?
  fi

  if [[ $activate == true ]] && [[ -d "${params[-1]}" ]]; then
    venv-activate "${params[-1]}"
  fi
}
