if (( $+commands[direnv] )); then
  alias tmux='direnv exec / tmux'
fi

# tma [session-name]
#
#   attaches or creates tmux session; detaches other clients.
#
tma() {
  tmux new-session -ADs "${1:-main}"
}
