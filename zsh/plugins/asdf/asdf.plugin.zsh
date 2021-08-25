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
: "${ASDF_DIR:=$HOME/.asdf}"
: "${ASDF_DATA_DIR:=$HOME/.asdf}"

# If not found, check for Homebrew package
if [[ ! -f $ASDF_DIR/asdf.sh ]] && (( $+commands[brew] )); then
   ASDF_DIR=$(brew --prefix asdf)
fi

# Load command
if [[ -f $ASDF_DIR/asdf.sh ]]; then
    source "$ASDF_DIR"/asdf.sh
fi

function asdf-install() {
  if [[ $# -eq 2 && $2 == latest ]]; then
    local tool=$1 version=$2
    shift 2
    set -- ${tool}@${version}
  fi
    
  for tool; do
    local -A parts=(${(s/@/)tool})
    local version

    tool=${parts[1]}
    version=${parts[2]}

    if [[ -z $version ]]; then
      version=$(
        { asdf list all "$tool" ; echo latest } |
          fzf --header="$tool versions" --prompt='version to install: ' --tac --no-sort
      ) || return $?
    fi

    asdf install "$tool" "$version" &&
      asdf global "$tool" "$version"
  done
}

function asdf-plugin-add() {
  local query=$1
  local plugins
  local plugin_name

  plugins=$(comm -23 <(find "${ASDF_DIR?}"/repository/plugins -maxdepth 1 -exec basename {} \; | sort) <(asdf plugin list | sort) | fzf --multi --query="$query")

  for plugin_name in "$plugins"; do
    asdf plugin add "$plugin_name" || continue
    if read -q "?install ${tool}@latest? (y/n) "; then
      asdf-install "$plugin"@latest || continue
    fi
  done
}

function asdf-upgrade() {
  (($#)) || set -- $(asdf list 2>/dev/null | grep -v '^[ ]' | fzf)

  for tool; do
    local version
    local current_version current_version_scope

    if [[ $tool == *'@'* ]]; then
      IFS=@ read -r tool version
    fi

    # capture current version information
    read -r current_version current_version_scope < <(asdf current "$tool" 2>/dev/null | awk '{ print $2, $3 }')

    # pick a new version
    if [[ -z $version ]]; then
      version=$(
        { comm -23 <(asdf list all "$tool" | sort) <(printf %s "$current_version") ; echo latest } |
          fzf --header="$tool versions" --prompt='version to install: ' --tac --no-sort
      ) || return $?
    fi

    asdf install "$tool" "$version" || return $?
    printf 'Installed %s %s\n' "$tool" "$version"

    # Update tool-versions
    # nothing to do in edge case where version didnt change
    if [[ $version != $current_version ]]; then
      if read -q "?Set global version? (asdf global $tool $version) [y/N]: "; then
        asdf global "$tool" "$version"
        if [[ -n $current_version ]] && read -q "?Uninstall previous version? (asdf uninstall $tool $current_version?) [y/N]: "; then
          asdf uninstall "$tool" "$current_version"
        fi
      fi
    fi
  done
}
