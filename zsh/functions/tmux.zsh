# @name tma
# @description attaches or creates tmux session; detaches other clients.
function tma() {
  tmux new-session -ADs "${1:-main}"
}

