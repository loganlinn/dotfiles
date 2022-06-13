# functions.zsh

function command_exists() {
  (( $+commands[$1]))
}

function function_exists() {
  (( $+functions[$1]))
}

# @doc Bulk search & replace with ag (the_silver_searcher)
function agr {
	ag -0 -l "$1" | AGR_FROM="$1" AGR_TO="$2" xargs -0 perl -pi -e 's/$ENV{AGR_FROM}/$ENV{AGR_TO}/g'
} 

function br {
	if ! type -p broot >/dev/null 2>&1; then
		if type -p cargo >/dev/null 2>&1; then
			echo "Installing broot from crates.io..." >&2
			cargo install broot >&2
		fi
		if ! type -p broot >/dev/null 2>&1; then
			echo "broot command not found!" >&2
			echo "Visit 'https://dystroy.org/broot' for installation information." >&2
			return 1
		fi
	fi

	local cmd cmd_file code
	cmd_file=$(mktemp)
	if broot --outcmd "$cmd_file" "$@"; then
		cmd=$(<"$cmd_file")
		rm -f "$cmd_file"
		eval "$cmd"
	else
		code=$?
		rm -f "$cmd_file"
		return "$code"
	fi
}

function gpg_restart() {
  pkill gpg
  pkill pinentry
  pkill ssh-agent
  eval "$(gpg-agent --daemon --enable-ssh-support)"
}

# @name tma
# @description attaches or creates tmux session; detaches other clients.
function tma() {
  tmux new-session -ADs "${1:-main}"
}

