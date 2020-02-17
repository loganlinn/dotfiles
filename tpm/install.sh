#!/bin/sh
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "› installing tmux plugin manager"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
