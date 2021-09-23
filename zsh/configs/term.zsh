#!/usr/bin/env zsh

# fixes a strange issue where every keypress was accompanied by 'tmux' or 'tmux;'
# unclear if a tmux-related zsh plugin or jetbrains pty is at fault,
# but we definitely don't need tmux inside IDE ~_~
if [ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]; then
  unset TMUX
fi
