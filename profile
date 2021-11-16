#!/bin/sh

ENV=$HOME/.shrc

# xdg
# ------------
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME"/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME"/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME"/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME"/.local/state}

# fzf
# ------------
export FZF_TMUX=1
export FZF_DEFAULT_OPTS="--color 'bg+:239,marker:226'"
export FZF_CTRL_R_OPTS="--sort"
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --no-messages --glob "!.git/"'
export FZF_CTRL_T_OPTS="--preview 'bat {} --color=always --line-range :30'"
export FZF_ALT_C_COMMAND='fasd_cd -d -l -R'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# pyenv
# ------------
if [ -d "${PYENV_ROOT:=$HOME/.pyenv}" ]; then
  export PYENV_ROOT
	export PYENV_VIRTUALENV_DISABLE_PROMPT=1
	export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init --path)"
fi

# rust
# ------------
[ -e "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# nix
# ------------
[ -f "$HOME"/.nix-profile/etc/profile.d/nix.sh ] && . "$HOME"/.nix-profile/etc/profile.d/nix.sh

# locals
# ------------
[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
