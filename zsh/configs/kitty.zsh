#!/usr/bin/env zsh

if (( $+commands[kitty] )); then
  kitty + complete setup zsh | source /dev/stdin
fi
