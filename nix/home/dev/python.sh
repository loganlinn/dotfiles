# prints path to venv directory given path argument(s), defaulting to the working directory.
# if multiple venvs exist, shows interactive selection menu.
select-venv() {
  fd -u pyvenv.cfg "$@" -x echo "{//}" |
    fzf --select-1 --exit-0 \
      --header "select python venv" \
      --preview '{}/bin/pip list --disable-pip-version-check --no-python-version-warning' &&
    return 0
  if [[ $? != 130 ]]; then echo >&2 "no venv found in ${*:-$PWD}"; fi
  return 1
}

activate-venv() {
  local venv
  venv=$(select-venv "$@") || return $?
  # shellcheck disable=1091
  source "$venv/bin/activate" &&
    echo "✅ activated: $venv"
}
