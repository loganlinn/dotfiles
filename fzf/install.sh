#!/bin/bash
if [ -d "/usr/local/opt/fzf" ]; then
    export FZFHOME="/usr/local/opt/fzf"
else
    export FZFHOME="$HOME/.fzf"
fi


if [ ! -d "$FZFHOME" ] ; then
  echo "  ==> Installing fzf"
  git clone --depth 1 https://github.com/junegunn/fzf "$FZFHOME" 
  "$FZFHOME/install" --bin --64 --no-update-rc
fi