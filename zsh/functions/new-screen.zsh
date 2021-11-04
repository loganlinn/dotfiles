#!/usr/bin/env zsh

new-screen() {
  [[ -z $STY ]] || screen < "$TTY"
  [[ -z $TMUX ]] || tmux new-window
}

# Bind to F12
zle -N new-screen
[[ -z "$terminfo[kf12]" ]] || bindkey "$terminfo[kf12]" new-screen

