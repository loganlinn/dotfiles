#!/bin/zsh

PROJECTS="${PROJECTS:-"$HOME/code"}"

# @description lets you quickly jump into a project directory.
function c () {
  if [[ "$1" == "/" ]]; then
    cd "$PROJECTS"
    return
  fi

  # if project not specified, prompt for it (in a fuzzy fashion)
  if [ "$#" -eq "0" ] || [ ! -d "$PROJECTS/$1" ]; then
    preview_cmd="git --git-dir=$PROJECTS/{}/.git status 2>/dev/null || tree --dirsfirst -FL 1"
    choice=$(CLICOLOR=0 ls -c "$PROJECTS" | fzf-tmux --query="$1" --preview "$preview_cmd")
    if [ $? -ne 0 ]; then
      return
    fi
  else
    choice="$1"
  fi


  if [[ -d "$PROJECTS/$choice" ]]; then
    cd "$PROJECTS/$choice"

    tmux rename-window "$choice"

    # [python]
    # if no venv is activated and there's a pyenv version with matching
    # name, activate it automatically
    if [ -z "$VIRTUAL_ENV" ]; then
      pyenv activate "$choice" 2>/dev/null
    fi
  else
    cd "$PROJECTS"
  fi
}

# @description clones git repository (including submodules) and changes working
# directory to it. If `directory` not specified, uses $PROJECTS.
# and if that's not set, fallsback to current directory.
#
# @example cclone git@github.com:loganlinn/blog.git
# @example cclone loganlinn/blog
function cclone {
  emulate -L zsh

  if [[ "$#" -eq 0 ]]; then
    echo "Usage: $0 <repository> [<directory>]" >&2
    return 1
  fi

  local repository="$1"
  local directory="$2"

  if [[ -z "$directory" ]]; then
    directory="${PROJECTS:-$(pwd)}/${repository:t:r}"
  fi

  git clone --recurse-submodules --shallow-submodules -- "$repository" "$directory" &&
  cd "$directory"
}
