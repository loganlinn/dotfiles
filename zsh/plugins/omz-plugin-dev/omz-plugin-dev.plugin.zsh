#!/usr/bin/env zsh

# Extends the 'omz plugin' family of commands for plugin development.

function _omz::plugin::create {
  local plugin=$1

  if [[ -z ${plugin+x} ]]; then
    echo >&2 "Usage: omz plugin create <plugin>"
    return 1
  fi

  if _omz::plugin::info "$plugin" >/dev/null 2>&1; then
    _omz::log info "a plugin named '$plugin' already exists"
    return 1
  fi

  local plugin_dir="${ZSH_CUSTOM?}/plugins/${plugin}"
  mkdir -p "$plugin_dir"

  # If command is being piped, redirect into plugin script
  if [[ ! -t 1 ]]; then
    exec > "$plugin_dir/${plugin}.plugin.zsh"
  else
    touch "$plugin_dir/${plugin}.plugin.zsh"
    _omz::log info "created $plugin_dir/${plugin}.plugin.zsh"
  fi
}

function _omz::plugin::edit {
  local plugin=$1

  if [[ -z ${plugin+x} ]]; then
    >&2 echo "Usage: omz plugin edit <plugin>"
    return 1
  fi

  if ! [[ -f "${ZSH_CUSTOM}/plugins/${1}/${1}.plugin.zsh" ]]; then
    if [[ -f "${ZSH}/plugins/${1}/${1}.plugin.zsh" ]]; then
      _omz::log error "'${plugin}' is an official plugin. Use: omz plugin overrride '${plugin}'"
    else
      _omz::log error "'${plugin}' plugin not found"
    fi
    return 1
  fi

  $EDITOR "${ZSH_CUSTOM}/plugins/${1}/${1}.plugin.zsh"
}

function _omz::plugin::delete {
  local plugin=$1 ; shift

  if [[ -z ${plugin+x} ]]; then
    >&2 echo "Usage: omz plugin delete <plugin>"
    return 1
  fi

  local plugin_dir="${ZSH_CUSTOM?}/plugins/${plugin}"

  if [[ ! -d $plugin_dir ]]; then
    _omz::log error "cannot delete '$plugin': no such directory $plugin_dir"
    return 1
  fi

  if read -q "?remove directory '$plugin_dir'? (y/n) "; then
    rm -r "$plugin_dir"
  fi
}
