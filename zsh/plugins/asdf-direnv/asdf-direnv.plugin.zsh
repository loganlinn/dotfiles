#!/usr/bin/env zsh

eval "$(asdf exec direnv hook zsh)"

direnv() { asdf exec direnv "$@"; }
