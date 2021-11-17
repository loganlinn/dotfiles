# ~/.bashrc: user-specifc .bashrc file for bash(1).

[ -z "$PS1" ] && return

. ~/.shrc

[ -e "$XDG_CONFIG_HOME"/fzf/fzf.bash ] &&
  . "$XDG_CONFIG_HOME"/fzf/fzf.bash

[ -e ~/.bashrc.local ] &&
  . ~/.bashrc.local

if hash starship 2>/dev/null; then
  eval "$(starship init bash)"
fi

