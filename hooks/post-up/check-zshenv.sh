#!/usr/bin/env sh

# detect old OS X broken /etc/zshenv and suggest rename
# credit: https://github.com/thoughtbot/dotfiles/blob/2a59c1890f81bffc1db79cae4482ce2b706b0f79/hooks/post-up

if grep -qw path_helper /etc/zshenv 2>/dev/null; then
  dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

  cat <<MSG >&2
Warning: \`/etc/zshenv' configuration file on your system may cause unexpected
PATH changes on subsequent invocations of the zsh shell. The solution is to
rename the file to \`zprofile':
  sudo mv /etc/{zshenv,zprofile}
(called from ${dir}/post-up:${LINENO})
MSG
fi
