#!/usr/bin/env zsh
# ------------------------------------------------------------------------------
#          FILE:  asdf.plugin.zsh
#   DESCRIPTION:  asdf plugin file.
# ------------------------------------------------------------------------------

# shellcheck shell=bash

: "${ASDF_DIR:=$HOME/.asdf}"
: "${ASDF_DATA_DIR:=$HOME/.asdf}"

if ! [[ -d $ASDF_DIR ]]; then
	echo "Installing asdf..." >&2
	git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
fi

source "$ASDF_DIR"/asdf.sh

alias asdff=asdff
alias asdfu=asdf-upgrade
alias asdft='asdf latest'
alias asdfv='asdf current'

function asdff() {
	local command
	if [[ -n $1 ]] && type asdff-"$1" >/dev/null 2>&1; then
		command=$1
	else
		command=$(asdff-commands | fzf --prompt="asdff command: " --exit-0 --select-1 --query="$1") || return $?
	fi
	if ! type asdff-"$command" >/dev/null 2>&1; then
		echo "asdff: '$command' is not a valid command" >&2
		return 1
	fi
	[[ $# -eq 0 ]] || shift
	asdff-"$command" "$@"
}

 # prints command that can be invoked asdff-<command>, then strips the stem
function asdff-commands() {
 # explaination:
 #         functions :: built-in associative array maps names of enabled functions to their definitions.
 #       ${(ok)assoc} :: expands associative array into array of ordered keys
 #  array[(I)asdff-*] :: expands to all array indexes of values that match
 #            #asdf-* :: pattern removal from the head of string (for each array item)
 print -l ${(ok)functions[(I)asdff-*]#asdff-*}
}

function asdff-install() {
	if [[ $# -eq 0 ]]; then # select tool to install interactively
		set -- $(asdf list 2>/dev/null | grep -v '^[ ]' | fzf)
	elif [[ $# -eq 2 ]]; then # best-effort to mimic normal `asdf install`
		if [[ $2 == latest ]] || ! grep -q "$2" <(asdf plugin list); then
			local name=$1 version=$2
			shift 2
			set -- ${name}@${version}
		fi
	fi

	local spec
	for spec; do
     # cleanup 'name@version' input form
		local name=${spec%@*}

		# update or install plugin
		asdf plugin update "$name" || asdff-add "$name" || return $?

		asdff-upgrade "$spec"
	done
}

function asdff-add() {
	local query=$1
	{
		comm -23 \
			<(find "${ASDF_DIR?}"/repository/plugins -maxdepth 1 -exec basename {} \; | sort) \
			<(asdf plugin list | sort) |
			fzf --multi --exit-0 --select-1 --query="$query"
	} | while read -r name; do
		asdf plugin add "$name" || return $?
		echo "Added plugin: $name" >&2
		if [[ $command == add ]] && read -q "?  Install $name@latest? (y/N) "; then
			asdf install "$name" latest
		fi
	done
}

function asdff-uninstall() {
	local name=$1
	local versions
	local version

	name=$(asdf plugin list |
		fzf --prompt="plugin: " --exact --exit-0 --select-1 --query="$name") ||
		return $?

	if [[ $# -gt 0 ]]; then
		shift
	fi

	versions=$(asdf list "$name" |
		awk '{ print $1 }' |
		fzf --multi --tiebreak=begin --exit-0 --bind=ctrl-a:select-all --query="$@") ||
		return $?

	# advertise the destruction
	print -l "Uninstalling $name versions:" $versions >&2

	if [[ -n $versions ]] && read -q "?Proceed? [y/N]: "; then
		echo >&2 # ensure new line afer prompt

		for version in "$versions"; do
			asdf uninstall "$name" "$version"
			print -l "$name"
		done
	fi
}

function asdff-remove() {
	for name; do
		asdff-uninstall "$name" || return $?
	done
}

function asdff-update() {
	local query=$1
	local name names
	names=$(asdf plugin list | fzf --multi --exit-0 --select-1 --query="$query")
	for name in "$names"; do
		asdf plugin update "$name" || return $?
		echo "Updated plugin: $name" >&2
	done
}

function asdff-upgrade() {
	if [[ $# -eq 0 ]]; then # select tool to install interactively
		set -- $(asdf list 2>/dev/null | grep -v '^[ ]' | fzf)
	elif [[ $# -eq 2 ]]; then # best-effort to mimic normal `asdf install`
		if [[ $2 == latest ]] || !grep -q "$2" <(asdf plugin list); then
			local name=$1 version=$2
			shift 2
			set -- ${name}@${version}
		fi
	fi

	for name; do
		local version

		if [[ $name == *'@'* ]]; then
			IFS=@ read -r name version
		fi

		# if ! [[ -d ${ASDF_DATA_DIR?}/installs/$name ]]; then
			# if ! name=$(find "$ASDF_DATA_DIR"/installs -maxdepth 1 -type d -exec basename {} \; | fzf --prompt="name: " --select-1 --query="$name"); then
				# echo "upgrade: must specify installation" >&2
				# return 1
			# fi
		# fi

		# pick a new version
		if [[ -z $version ]]; then
			version=$(
				comm -23 <(asdf list all "$name" | sort) <(asdf list "$name" 2>/dev/null | awk '{ print $1 }' | sort) |
					cat - <<<'latest' |
					fzf --header="$name versions" --prompt="Version to install: " --tac --no-sort
			) || return $?
		fi

		# resolve "latest" -- this isn't necessary, but saves multiple look-ups that should be consistent.
		if [[ $version == latest ]]; then
			version=$(asdf latest "$name")
		fi

		local current
		current=$(asdf current "$name" 2>/dev/null | awk '{ print $2 }')

		printf 'Installing %s@%s...\n' "$name" "$version" >&2
		asdf install "$name" "$version" || return $?

		# Update tool-versions
		# nothing to do in edge case where version didnt change
		if [[ $version != $current ]]; then
			if read -q "?Set $name global version to $version? [y/N]: "; then
				printf \\n >&2 # separating line between prompts

				asdf global "$name" "$version" || return $?
        asdf current "$name"

				if [[ -n $current ]] && read -q "?Uninstall previous version? (asdf uninstall $name $current?) [y/N]: "; then
					asdf uninstall "$name" "$current"
				fi
			fi
		fi
	done
}

function asdff-list() {
	asdf plugin list "$@"
}

function asdff-list-all() {
	asdf plugin list -all "$@"
}

function asdff-update-all() {
	asdf plugin update -all "$@"
}
