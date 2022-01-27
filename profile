#!/usr/bin/env sh
#
# shellcheck disable=SC1090,SC1091

export ENV="$HOME/.shrc"

# export GIT_CURL_VERBOSE=true
# export GIT_CONFIG_NOSYSTEM=true
# export GIT_TRACE=true
# export GIT_TRACE_PACKET=true
# export GIT_TRACE_PERFORMANCE=true
# export GIT_TRACE_SETUP=true

export FZF_DEFAULT_OPTS="--color 'bg+:239,marker:226'"
export FZF_CTRL_R_OPTS="--sort"
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --no-messages --glob "!.git/"'
export FZF_CTRL_T_OPTS="--preview 'bat {} --color=always --line-range :30'"
export FZF_ALT_C_COMMAND='fasd_cd -d -l -R'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

export NIX_PATH="$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH"

# shellcheck disable=SC2016
export RESTIC_PASSWORD_COMMAND='bash -c "eval `op signin --session $OP_SESSION_my`; op get item --fields password nrqwkl5ihm2b45iyijubvjzhxm"'

[ -e "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

[ -e "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"

[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && . "$HOME/.nix-profile/etc/profile.d/nix.sh"

[ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

if [ -d "$HOME/.profile.d" ]; then
  for f in "$HOME"/.profile.d/*; do
    if [ -f "$f" ]; then . "$f"; fi
  done
  unset f
fi

PATH="$HOME/.krew/bin:$PATH"
PATH="$HOME/.deno/bin:$PATH"
PATH="$HOME/.local/share/flatpak/exports/bin:$PATH"
PATH="$HOME/.fzf/share/bin:$PATH"
PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export PATH

## Host

[ -e "$HOME/.profile.local" ] &&
  . "$HOME/.profile.local"
