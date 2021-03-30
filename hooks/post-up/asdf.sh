#!/usr/bin/env bash

if [[ ${DEBUG-} =~ ^1|yes|true$ ]]; then
	set -o xtrace
fi

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=../../local/lib/dotfiles/source.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../local/lib/dotfiles/source.sh"
# shellcheck source=../../local/lib/dotfiles/functions.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../local/lib/dotfiles/functions.sh"

trap script_trap_err ERR
trap script_trap_exit EXIT

script_init "$@"
colour_init

##################################################################################

function git-checkout-latest-tag() {
	local git_dir=$1
	local tag
	tag=$(git -C "$git_dir" describe --abbrev=0 --tags)
	git -C "$git_dir" checkout tags/"$tag" -B "$tag"
}

##################################################################################

ASDF_DIR=${ASDF_DIR:-$HOME/.asdf}

if [[ ! -d $ASDF_DIR ]]; then
	git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
	git-checkout-latest-tag "$ASDF_DIR"
fi

# add asdf plugins, ignoring  those that are not currently installed
function asdf-plugin-up() {
  sed "/^$(asdf plugin-list | sed ':a; N; $!ba; s/\n/\\|/g')/d" \
    | xargs -t asdf plugin-add
}

asdf-plugin-up <<'EOF'
clojure
elixir
elm
fzf
golang
java
lua
nodejs
python
ruby
rust
yarn
zig
arkade https://github.com/asdf-community/asdf-arkade
direnv https://github.com/asdf-community/asdf-direnv
doctl https://github.com/maristgeek/asdf-doctl.git
EOF

asdf info
