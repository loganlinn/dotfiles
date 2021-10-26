#!/usr/bin/env zsh

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
