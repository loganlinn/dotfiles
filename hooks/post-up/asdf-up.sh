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

# @brief adds asdf plugins that are not already registered
# @description
#     - Reads arguments to `asdf plugin-add` from stdin or file argument.
#     - Ignores lines starting with '#'
#     - Ignores lines starting with name of plug that is currently installed
#     - Runs `asdf plugin-add` on the rest
asdf_plugins_init() {
	local -r ignore_prefixes=$(printf '# %s' "$(asdf plugin-list)" | xargs echo)
	sed -e "/^${ignore_prefixes// /\\|}/d" "${1-}" | xargs -r -t -L1 asdf plugin-add
}

# shellcheck disable=SC2001
function info_section() {
  local -r heading=$1
	>&2 echo -e "\033[1m${heading}\033[m"
  >&2 echo
  >&2 sed -e "s/^/    /"
  >&2 echo
}

function main() {
	if ! [[ -d $ASDF_DIR ]]; then
		git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
  fi

	# shellcheck source=/dev/null
	source "${ASDF_DIR}/asdf.sh"

  asdf update 2>/dev/null

	# initialize plugins
	if [[ -f ~/.asdf-plugins ]]; then
		asdf_plugins_init ~/.asdf-plugins
	fi

  # print asdf info
  asdf version | info_section "ASDF VERSION"
  env | grep '^ASDF_' | info_section "ASDF ENVIRONMENT VARIABLES"
  asdf plugin list --urls | info_section "ASDF PLUGINS"
}

main
