setopt hist_ignore_all_dups inc_append_history

HISTFILE=$HOME/.zhistory
HISTSIZE=65536
SAVEHIST=65536

export ERL_AFLAGS="-kernel shell_history enabled"
