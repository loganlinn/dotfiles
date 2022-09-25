# ~/.zshrc: user-specifc .zshrc file for zsh(1).

# zmodload zsh/zprof

[ -z "$PS1" ] && return

ZSH_CONFIG=$HOME/.zsh

source $HOME/.shrc

typeset -ga sources

sources+="$ZSH_CONFIG/environment.zsh"
sources+="$ZSH_CONFIG/options.zsh"
sources+="$ZSH_CONFIG/path.zsh"
sources+="$ZSH_CONFIG/functions.zsh"
sources+="$ZSH_CONFIG/aliases.zsh"
sources+="$ZSH_CONFIG/$(uname -s | tr '[:upper:]' '[:lower:]').zsh"
sources+="/etc/zsh_command_not_found"
sources+="$ZSH_CONFIG/clipboard.zsh"
sources+="$ZSH_CONFIG/antigen.zsh"
sources+="$ZSH_CONFIG/completion.zsh"
sources+="$ZSH_CONFIG/keybindings.zsh"
sources+="$ZSH_CONFIG/surround.zsh"
sources+="$ZSH_CONFIG/kitty.zsh"
sources+="$HOME/.fzf/shell/completion.zsh"
sources+="$HOME/.fzf/shell/key-bindings.zsh"
sources+="$HOME/.asdf/plugins/java/set-java-home.zsh"

# And we're off...
foreach file ("$sources[@]")
    if [[ -a $file ]]; then
        source $file
    fi
end

unset file sources

if command_exists starship; then
  eval "$(starship init zsh)"
fi

if command_exists zoxide; then
  eval "$(zoxide init zsh)"
fi

if command_exists direnv; then
  eval "$(direnv hook zsh)"
fi

if [[ -a $HOME/.zshrc.local ]]; then
  source "$HOME/.zshrc.local"
fi

#
#zprof
