#!/usr/bin/env zsh

asdf-upgrade() {
	local tool=$1
	local version=$2

	[[ -n $tool ]] || tool=$(asdf list 2>/dev/null | grep -v '^[ ]' | fzf) || return $?
	printf 'upgrading %s\n...' "$tool"
	[[ -n $version ]] || version=$(asdf list all "$tool" | fzf --header="$tool versions" --prompt='version to install: ' --tac --no-sort) || return $?

	# Perform install
	printf '-> asdf install %s %s\n' "$tool" "$version"
	asdf install "$tool" "$version" || return $?

	# Update tool-versions
	local tool_versions_filename=${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME:-.tool-versions}
	local current_version current_version_scope
	read -r current_version current_version_scope < <(asdf current "$tool" 2>/dev/null | awk '{ print $2, $3 }')

	# nothing to do in edge case where version didnt change
	[[ $version != $current_version ]] || return 0

	if [[ $current_version_scope == ~/"$tool_versions_filename" ]]; then
		if read -q "?asdf global $tool $version? (y/n) "; then
			asdf global "$tool" "$version"
		fi
	elif [[ $current_version_scope == *"environment variable" ]]; then
		if read -q "?asdf shell $tool $version? (y/n) "; then
			asdf shell "$tool" "$version"
		fi
	else
		if read -q "?asdf local $tool $version? (y/n) "; then
			asdf local "$tool" "$version"
		fi
	fi
	echo

	if [[ -n $current_version ]]; then
		if read -q "?asdf uninstall $tool $current_version? (y/n) "; then
			asdf uninstall "$tool" "$current_version"
		fi
	fi
	echo
}
