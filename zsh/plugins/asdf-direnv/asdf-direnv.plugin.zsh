#!/usr/bin/env zsh

if (($+commands[asdf])); then
  if (($+commands[direnv])); then
    eval "$(asdf exec direnv hook zsh)"
    direnv() { asdf exec direnv "$@"; }
  fi
fi
