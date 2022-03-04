#!/usr/bin/env zsh
# Enable some of some functionality of the popular vim surround plugin.
# See: https://github.com/zsh-users/zsh/blob/master/Functions/Zle/surround 
autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround
bindkey -a cs change-surround
bindkey -a ds delete-surround
bindkey -a ys add-surround
bindkey -M visual S add-surround
