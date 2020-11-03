command -v gco

# @name gco
# @description checkout branch if given, otherwise choose interactively from recent branches
# @arg $1 string branch
# @arg $@ any git-checkout args
function gco() {
  if [ $# -eq 0 ]; then
    local branches branch
    branches="$(git branch --sort=-committerdate)" &&
      branch="$(echo "$branches" | fzf-tmux -d 15 +m)"
    if [ $? -eq 0 ]; then
      git checkout "$(echo "$branch" | sed "s/.* //")"
    fi
  else
    git checkout -B "$@"
  fi
}

function gitignore.io() {
  http GET "https://www.gitignore.io/api/$@" --follow --body
}

_gitignoreio_get_command_list() {
  curl -sL https://www.gitignore.io/api/list | tr "," "\n"
}

_gitignoreio () {
  compset -P '*,'
  compadd -S '' `_gitignoreio_get_command_list`
}

compdef _gitignoreio gitignoreio

