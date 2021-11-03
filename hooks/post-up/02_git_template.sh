#!/bin/sh

# credit: https://github.com/thoughtbot/dotfiles/blob/2a59c1890f81bffc1db79cae4482ce2b706b0f79/hooks/post-up

if [ -f "$HOME/.git_template/HEAD" ] && \
  [ "$(cat "$HOME/.git_template/HEAD")" = "ref: refs/heads/main" ]; then
  echo "Removing ~/.git_template/HEAD in favor of defaultBranch" >&2
  rm -f ~/.git_template/HEAD
fi
