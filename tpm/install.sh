#!/bin/sh
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo "› installing tmux plugin manager"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo "› skipping tmux plugin manager"
fi
