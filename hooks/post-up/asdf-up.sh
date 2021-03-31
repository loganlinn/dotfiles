#!/usr/bin/env bash

# @name asdfup
# @brief Install and configure asdf version manager
# @description
#     This can be used to boostrap asdf on a clean machine.
#     Enables plugins to be configured via file.
#     Designed to be used as pre/post-up hook for [rcm](https://github.com/thoughtbot/rcm).
# @see https://asdf-vm.com

[[ ${TRACE-} ]] && set -x

set -euo pipefail

ASDF_DIR=${ASDF_DIR:-$HOME/.asdf}

function asdf_dir_bootstrap() {
	if [[ ! -d ${ASDF_DIR?} ]]; then
		git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
		(
			cd "$ASDF_DIR"
			tag=$(git describe --abbrev=0 --tags)
			git checkout -q "tags/${tag}" -b "$tag"
		)
	fi
}

# @brief adds asdf plugins that are not already registered
# @description
#     - Reads arguments to `asdf plugin-add` from stdin or file argument.
#     - Ignores lines starting with '#'
#     - Ignores lines starting with name of plug that is currently installed
#     - Runs `asdf plugin-add` on the rest
asdf_plugins_init() {
	local -r ignore_prefixes=$(printf '# %s' "$(asdf plugin-list)" | xargs echo)
	sed "/^${ignore_prefixes// /\\|}/d" "${1-}" | xargs -r -t -L1 asdf plugin-add
}

function strong_echo() {
	echo -e "\033[1m${*}\033[m"
}

function main() {
	asdf_dir_bootstrap

	# shellcheck source=/dev/null
	source "${ASDF_DIR}/asdf.sh"

	# initialize plugins
	if [[ -f ~/.asdf-plugins ]]; then
		asdf_plugins_init ~/.asdf-plugins
	fi

	local -r pad="    "
	strong_echo ASDF VERSION
	printf "\n%s\n\n" "${pad}$(asdf version)"
	strong_echo "ASDF ENVIRONMENT VARIABLES"
	printf "\n%s\n\n" "$(env | grep '^ASDF_' | sed "s/^/${pad}/")"
	strong_echo "ASDF PLUGINS:"
	printf "\n%s\n\n" "$(asdf plugin list --urls | sed "s/^/${pad}/")"
}

main
