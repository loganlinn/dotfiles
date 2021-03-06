alias deact="pyenv deactivate"

# @description activates a pyenv-managed virtualenv based on args, pwd, or fzf choice
act() {
  local env="$1"

  if [[ "$#" -ne "0" ]]; then
    pyenv activate "$1"
    return 0
  fi

  if [[ -z "${VIRTUAL_ENV:-}" ]]; then
    project=$(basename $(git rev-parse --show-toplevel 2>/dev/null || pwd))
    if [[ -d "$PYENV_ROOT/versions/$project" ]]; then
      pyenv activate "$project"
      return 0
    fi
  fi

  choice=$(pyenv virtualenvs --bare | awk '/[-.0-9]+\/envs\//{next;}{print $1}' | fzf --select-1 --query="$env")
  if [[ -n "$choice" ]]; then
    pyenv activate "$choice"
    return 0
  fi

  return 1
}

# _act_virtualenv_list() {
#   pyenv virtualenv --complete
# }

# _act() {
#   compadd $(_act_virtualenv_list)
# }


# compdef _act act
