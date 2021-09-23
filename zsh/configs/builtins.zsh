#!/usr/bin/env zsh

# Expose zsh's `run-help` function for getting help on built-ins.
# First, remove the crappy standard alias run-help=man
(( ! $+aliases[run-help] )) || unalias run-help
autoload -Uz run-help

