HISTFILE="$HOME/.zsh_history"
HISTSIZE=65536
SAVEHIST=65536

setopt EXTENDED_HISTORY         # Record timestamp of command in HISTFILE
setopt HIST_EXPIRE_DUPS_FIRST   # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS         # Ignore duplicated commands history list
setopt HIST_IGNORE_SPACE        # Ignore commands that start with space
setopt HIST_VERIFY              # Show command with history expansion to user before running it
setopt INC_APPEND_HISTORY       # Append to the history file after command executed, not just when a term is killed
setopt SHARE_HISTORY            # Share command history data
