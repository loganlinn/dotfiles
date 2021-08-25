#!/usr/bin/env zsh
# ------------------------------------------------------------------------------
#          FILE:  asdf.plugin.zsh
#   DESCRIPTION:  asdf plugin file.
# ------------------------------------------------------------------------------
# Standarized $0 handling, following:
# https://github.com/zdharma/Zsh-100-Commits-Club/blob/master/Zsh-Plugin-Standard.adoc
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Find where asdf should be installed
ASDF_DIR="${ASDF_DIR:-$HOME/.asdf}"

# If not found, check for Homebrew package
if [[ ! -f $ASDF_DIR/asdf.sh ]] && (( $+commands[brew] )); then
   ASDF_DIR=$(brew --prefix asdf)
fi

# Load command
if [[ -f $ASDF_DIR/asdf.sh ]]; then
    source "$ASDF_DIR"/asdf.sh
fi

function asdf_install {
  for tool; do
    local -A parts=(${(s/@/)tool})
    local version
    tool=${parts[1]}
    version=${parts[2]}
    if [[ -z $version || $version == latest ]]; then
      version=$(asdf latest "$tool")
    fi
    asdf install "$tool" "$version"
    asdf global "$tool" "$version"
  done
}
