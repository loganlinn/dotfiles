which() {
	if result=$( (
		alias
		declare -f
	) | command which --tty-only --read-alias --read-functions --show-tilde --show-dot "$@"); then

		while IFS= read -r x; do
			if [[ -x $x ]]; then
				readlink -e "$x"
			else
				printf "%s\n" "$x"
			fi
		done <<<"$result"
	else
		status=$?
		echo "$result"
		return "$status"
	fi
}
