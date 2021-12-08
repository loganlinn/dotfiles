#!/usr/bin/env zsh


# load our own completion functions
fpath=(~/.zsh/{completion,functions} ~/.asdf/completions /usr/local/share/zsh/site-functions $fpath)

setopt extendedglob local_options

autoload -Uz compinit

local zcompf="${ZDOTDIR:-$HOME}/.zcompdump"
# use a separate file to determine when to regenerate, as compinit doesn't always need to modify the compdump
local zcompf_a="${zcompf}.augur"

if [[ -e "$zcompf_a" && -f "$zcompf_a"(#qN.md-1) ]]; then
    compinit -C -d "$zcompf"
else
    compinit -d "$zcompf"
    touch "$zcompf_a"
fi

# if zcompdump exists (and is non-zero), and is older than the .zwc file, then regenerate
if [[ -s "$zcompf" && (! -s "${zcompf}.zwc" || "$zcompf" -nt "${zcompf}.zwc") ]]; then
    # since file is mapped, it might be mapped right now (current shells), so rename it then make a new one
    [[ -e "$zcompf.zwc" ]] && mv -f "$zcompf.zwc" "$zcompf.zwc.old"
    # compile it mapped, so multiple shells can share it (total mem reduction)
    # run in background
    { zcompile -M "$zcompf" && command rm -f "$zcompf.zwc.old" }&!
fi 

if (( $+commands[kitty] )); then
  kitty + complete setup zsh | source /dev/stdin
fi

compdef _rg hg