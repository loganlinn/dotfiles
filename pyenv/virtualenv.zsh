
# activate a virtualenv or use fzf to select one
act() {
  local env="$1"
  if [[ ( -z "$env" ) || (! -d "$PYENV_ROOT/$env") ]]; then
    env=$(pyenv virtualenvs | awk '/[-.0-9]+\/envs\//{next;}{print $1}' | fzf --select-1 --query="$env")
  fi
  pyenv activate "$env"
}


deact() {
  pyenv deactivate
}
