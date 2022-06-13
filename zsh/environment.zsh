# environment.zsh
#

export VISUAL=${commands[nvim]:-$commands[vim]}
export EDITOR=$VISUAL

# Do not track....
export DOCKER_SCAN_SUGGEST=false
export NEXT_TELEMETRY_DISABLED=1
export HOMEBREW_NO_ANALYTICS=1

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc. on FreeBSD-based systems
CLICOLOR=1

# fixes a strange issue where every keypress was accompanied by 'tmux' or 'tmux;'
# unclear if a tmux-related zsh plugin or jetbrains pty is at fault,
# but we definitely don't need tmux inside IDE ~_~
if [[ "$TERMINAL_EMULATOR" -eq "JetBrains-JediTerm" ]]; then
  unset TMUX
fi

