#!/bin/sh

ENV=$HOME/.shrc

# see: https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME"/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME"/.local/state}

# see: https://github.com/pyenv/pyenv#installation
if [ -d "${PYENV_ROOT:=$HOME/.pyenv}" ]; then
  export PYENV_ROOT
	export PYENV_VIRTUALENV_DISABLE_PROMPT=1
	export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init --path)"
fi

if [ -e "$HOME/.cargo/env" ]                        ; then . "$HOME/.cargo/env"                        ; fi
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] ; then . "$HOME/.nix-profile/etc/profile.d/nix.sh" ; fi
if [ -e "$HOME/.profile.local" ]                    ; then . "$HOME/.profile.local"                    ; fi
