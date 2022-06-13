# @file options.zsh
#
# @docs https://zsh.sourceforge.io/Doc/Release/Options.html
#

# Enable extended globbing
setopt extendedglob

# Allow [ or ] whereever you want
unsetopt nomatch

# Do not exit shell when Ctrl-D pressed
setopt ignore_eof

setopt no_beep

###############################################################################
# History

# NOTE: INC_APPEND_HISTORY, INC_APPEND_HISTORY_TIME, and SHARE_HISTORY are considered mutually exclusive.

SAVEHIST=100000
HISTSIZE=100000
HISTFILE="$HOME/.zsh_history"

if (( ! EUID )); then
  HISTFILE=${HISTFILE}_root
fi

setopt share_history append_history extended_history hist_no_store hist_ignore_all_dups hist_ignore_space

setopt hist_expire_dups_first   # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups         # Ignore duplicated commands history list
setopt hist_ignore_space        # Ignore commands that start with space
setopt hist_verify              # Show command with history expansion to user before running it
setopt extended_history         # Record timestamp of command in HISTFILE
setopt inc_append_history       # Append to the history file after command executed, not just when a term is killed

# 2x control is completion from history!!!
zle -C hist-complete complete-word _generic
zstyle ':completion:hist-complete:*' completer _history
bindkey '^X^X' hist-complete

###############################################################################
# cd movements from zshkit
setopt autocd autopushd pushdminus pushdsilent pushdtohome cdablevars
DIRSTACKSIZE=5

###############################################################################
## Completion

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol     # disable output flow control via start/stop characters (i.e. ^S, ^Q)

setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word  # do not move cursor to end of word if completion is started
setopt always_to_end     # always move cursor to end of word when completion is inserted
setopt local_options
setopt completealiases


