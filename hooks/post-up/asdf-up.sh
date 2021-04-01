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

# shellcheck disable=SC2001
function info_section() {
  local -r heading=$1
	>&2 echo -e "\033[1m${heading}\033[m"
  >&2 echo
  >&2 sed -e "s/^/    /"
  >&2 echo
}

function asdf-missing-plugins() {
  cut -d' ' -f1 "${1--}" | sort \
    | comm -23 - <(asdf plugin-list | sort) \
    | join -a1 - <(asdf plugin list all)
}

function main() {
	if ! [[ -d $ASDF_DIR ]]; then
		git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
  fi

	# shellcheck source=/dev/null
	source "${ASDF_DIR}/asdf.sh"

  asdf update 2>/dev/null

	# setup tool plugins
  local -r plugins_to_add=$(asdf-missing-plugins "${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME:-$HOME/.tool-versions}")
  if [[ -n $plugins_to_add ]]; then
    xargs -t -L1 asdf plugin add
  fi

  # print asdf info
  asdf version | info_section "ASDF VERSION"
  env | grep '^ASDF_' | info_section "ASDF ENVIRONMENT VARIABLES"
  asdf plugin list --urls | info_section "ASDF PLUGINS"
}

main
