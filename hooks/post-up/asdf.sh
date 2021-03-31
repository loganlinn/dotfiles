#!/usr/bin/env bash

[[ ${TRACE-} =~ ^1|yes|true$ ]] && set -x
set -euo pipefail

ASDF_DIR=${ASDF_DIR:-$HOME/.asdf}

function install_asdf() {
	if [[ ! -d ${ASDF_DIR?} ]]; then
		git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
		(
			cd "$ASDF_DIR"
			tag=$(git describe --abbrev=0 --tags)
			git checkout -q "tags/${tag}" -b "$tag"
		)
	fi
}

function load_asdf_plugin_files() {
	for f in "$@"; do
		if [[ -f "$f" ]]; then
			<"$f" _strip_comments | _strip_existing_plugins | xargs -r -t -L1 asdf plugin-add
		fi
	done
}

function _strip_existing_plugins() {
	local -r plugins=$(asdf plugin-list)

	if [[ -n $plugins ]]; then
		sed "/^${plugins//$'\n'/\\|}/d"
	else
		cat -
	fi
}

function _strip_comments() {
	grep -v '#'
}

function main() {
	install_asdf

	# shellcheck source=/dev/null
	source "${ASDF_DIR}/asdf.sh"

	load_asdf_plugin_files ~/.asdf.plugins ~/.asdf.plugins.local

	# print summary
	printf "%s:\\n%s\\n\\n" "ASDF VERSION" "$(asdf version)"
	printf "%s:\\n%s\\n\\n" "ASDF ENVIRONMENT VARIABLES" "$(env | grep -E "^ASDF_*")"
	printf "%s:\\n%s\\n\\n" "ASDF INSTALLED PLUGINS" "$(asdf plugin list --urls)"
}

main
