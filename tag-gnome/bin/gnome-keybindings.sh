#!/usr/bin/env bash

set -e

PROG=$(basename -- "$0")

_error() {
	printf 'error: %s\n' "$1" >&2
	shift
	if [[ $# -gt 0 ]]; then
	  echo >&2
	  printf '%s\n' "$@" >&2
	fi
}

_help() {
	case $1 in
	help)
		echo "Usage:"
		echo "  $PROG help COMMAND"
		echo
		echo "Print help"
		echo
		echo "Arguments:"
		echo "  COMMAND     The (optional) command to explain"
		echo
		;;
	backup)
		echo "Usage:"
		echo "  $PROG backup [DIR]"
		echo
		echo "Backup settings to files"
		echo
		echo "Arguments:"
		echo "  DIR    The path to directory to write keyfiles (default: $(_keyfile | sed "s|$HOME|~|g"))"
		echo
		;;
	restore)
		echo "Usage:"
		echo "  $PROG restore [DIR]"
		echo
		echo "Restore settings from files"
		echo
		echo "Arguments:"
		echo "  DIR    The path to directory containing keyfiles (default: $(_keyfile | sed "s|$HOME|~|g"))"
		echo
		;;
	*)
		echo "Usage:"
		echo "  $PROG COMMAND [ARGS ...]"
		echo
		echo "Commands:"
		echo "  help       Show this information"
		echo "  backup     Backup settings to files"
		echo "  restore    Import settings files"
		echo
		echo "Use '$PROG help COMMAND' to get detailed help."
		echo
		;;
	esac
}

_keyfile() {
	local path=${1}
	local dir=${2:-"$HOME/.config/dconf/db/${PROG%.*}.d"}
	local name

	name=$path
	name=${name##/}
	name=${name%%/}
	name=${name//\//-}
	if [[ $path == */ ]]; then
		name="$name-dir"
	elif [[ -n $path ]]; then
		name="$name-val"
	fi

	printf '%s/%s' "$dir" "$name"
}

_backup() {
	local path=${1?}
	local file

	file=$(_keyfile "$path" "$2")

	mkdir -p "$(dirname -- "$file")"

	if [[ $path == */ ]]; then
		dconf dump "$path" >"$file"
	else
		dconf read "$path" >"$file"
	fi

	echo "unloaded ${file/$HOME/\~}"
}

_restore() {
	local path=${1?}
	local file

	file=$(_keyfile "$path" "$2")

	if [[ ! -f $file ]]; then
		_error "$file: no such file"
		return 1
	elif [[ ! -r $file ]]; then
		_error "$file: permission denied"
		return 1
	fi

	if [[ $path == */ ]]; then
		dconf reset -f "$path"
		dconf load "$path" <"$file"
	else
		dconf write "$path" "$(cat -- "$file")"
	fi

	echo "loaded ${file/$HOME/\~}"
}

command=$1

case $command in
"")
	_error "no command specified" "$(_help)"
	exit 1
	;;
help)
	shift
	_help "$@"
	;;
backup)
	shift
	_backup '/org/gnome/desktop/wm/keybindings/' "$@"
	_backup '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/' "$@"
	_backup '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings' "$@"
	;;
restore)
	shift
	_restore '/org/gnome/desktop/wm/keybindings/' "$@"
	_restore '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/' "$@"
	_restore '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings' "$@"
	;;
*)
	_error "unknown command '$command'" "$(_help)"
	exit 1
	;;
esac

exit $?
