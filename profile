# ~/.profile: user-specific .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

# shellcheck disable=SC1090

ENV=$HOME/.shrc

export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

export FZF_TMUX=1
export FZF_DEFAULT_OPTS="--color 'bg+:239,marker:226'"
export FZF_CTRL_R_OPTS="--sort"
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --no-messages --glob "!.git/"'
export FZF_CTRL_T_OPTS="--preview 'bat {} --color=always --line-range :30'"
export FZF_ALT_C_COMMAND='fasd_cd -d -l -R'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

[ -e "$HOME/.asdf/asdf.sh" ] &&
	. "$HOME/.asdf/asdf.sh"

[ -e "$HOME/.cargo/env" ] &&
	. "$HOME/.cargo/env"

# Detect pyenv installation
if [ -x "$HOME"/.pyenv/bin/pyenv ]; then
	export PYENV_ROOT=$HOME/.pyenv
	export PYENV_VIRTUALENV_DISABLE_PROMPT=1
	export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init --path)"
fi

if [ -d "$HOME/.profile.d" ]; then
	for i in "$HOME/.profile.d/"*; do
		! [ -f "$i" ] || . "$i"
	done
	unset i
fi

# https://github.com/NixOS/nix/issues/2033
[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] &&
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"

# home-manager
[ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] &&
	. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

[ -e "$HOME/.profile.local" ] &&
	. "$HOME/.profile.local"
