#!/usr/bin/env bash

[[ ${TRACE-} =~ ^1|yes|true$ ]] && set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

ASDF_DIR=${ASDF_DIR:-$HOME/.asdf}

ASDF_PLUGINS_PATHS=(
  "${SCRIPT_DIR}/../../asdf.plugins"
  ~/.asdf.plugins.local
)

function git-checkout-latest-tag() {
	local git_dir=$1
	local tag
	tag=$(git -C "$git_dir" describe --abbrev=0 --tags)
	git -C "$git_dir" checkout tags/"$tag" -B "$tag"
}

function setup_asdf_dir() {
  if [[ ! -d $ASDF_DIR ]]; then
    git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
    git-checkout-latest-tag "$ASDF_DIR"
  fi
}

# add asdf plugins, ignoring  those that are not currently installed
function asdf-plugin-up() {
  sed "/^$(asdf plugin-list | sed ':a; N; $!ba; s/\n/\\|/g')/d" \
    | xargs -t asdf plugin-add
}

function setup_asdf_plugins() {
  for f in ${ASDF_PLUGINS_PATHS[*]}; do
    if [[ -f $f ]]; then
      asdf-plugin-up < "$f"
    fi
  done
}

function reload_asdf() {
	# shellcheck source=../../../.asdf/asdf.sh
  source "${ASDF_DIR}/asdf.sh"
}

function print_asdf_summary() {
  printf "%s:\\n%s\\n\\n" "ASDF VERSION" "$(asdf version)"
  printf "%s:\\n%s\\n\\n" "ASDF ENVIRONMENT VARIABLES" "$(env | grep -E "^ASDF_*")"
  printf "%s:\\n%s\\n\\n" "ASDF INSTALLED PLUGINS" "$(asdf plugin list --urls)"
}

function main() {
  setup_asdf_dir
  setup_asdf_plugins
	reload_asdf
  print_asdf_summary
}

main
