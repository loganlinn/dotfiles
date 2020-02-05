# git clone helper
#
# clones git repo and of its submodules into the specified directory,
# then changes working directory. if directory not specified, uses PROJECTS,
# and if that's not set, fallsback to current directory.
# submodules fetched in parallel.
#
# requires: git 2.8+
# author: logan@loganlinn.com
function git-clone {
  REPO="$1"
  DIRECTORY="$2"

  if [ -z "$REPO" ]; then
    echo "usage: $0 <repository> [<directory>]"
    exit 1
  fi

  REPONAME="$(basename $REPO)"
  if [ -z "$DIRECTORY" ]; then
    DIRECTORY="${PROJECTS:-$PWD}/${REPONAME%.git}"
  fi

  hub clone --recurse-submodules --jobs 8 -- "$REPO" "$DIRECTORY"
  cd "$DIRECTORY"

  # needs to remember the current window when clone starts
  # if [ -n "$TMUX" ]; then
  #   tmux rename-window "$(basename DIRECTORY)"
  # fi
}

alias gclone="git-clone"

