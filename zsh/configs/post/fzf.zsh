#!/usr/bin/env zsh
# -----------------------------------------------------------------------------
#   fzf configuration
# -----------------------------------------------------------------------------
# docs: https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings

# start in a tmux split pane
export FZF_TMUX=1

# Color and appearances for fzf
# background color: use brighter and more visible color.
# marker: use yellow-ish color to make it more appearant
export FZF_DEFAULT_OPTS="--color 'bg+:239,marker:226'"

# CTRL_R: fzf-history-widget
export FZF_CTRL_R_OPTS="--sort"

# CTRL_T: fzf-file-widget
if (($+commands[rg])); then
	export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --no-messages --glob "!.git/"'
elif (($+commands[fd])); then
	export FZF_CTRL_T_COMMAND='fd --type f'
fi
if (($+commands[bat])); then
	export FZF_CTRL_T_OPTS="--preview 'bat {} --color=always --line-range :30'"
fi

# ALT_C: fzf-cd-widget
export FZF_ALT_C_COMMAND='fasd_cd -d -l -R'
if (($+commands[tree])); then
	export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
fi

# Load fzf key-bindings
# if [[ -z $FZF_INSTALL_PATH ]] && (($+commands[asdf])); then
# 	FZF_INSTALL_PATH=$(asdf where fzf)
# fi
# if [[ -f $FZF_INSTALL_PATH/shell/key-bindings.zsh ]] && [[ $TERM_PROGRAM != vscode ]]; then
# 	. "$FZF_INSTALL_PATH/shell/key-bindings.zsh"
# fi

# Directly executing the command (CTRL-X CTRL-R)
fzf-history-widget-accept() {
	fzf-history-widget
	zle accept-line
}
zle -N fzf-history-widget-accept
bindkey '^X^R' fzf-history-widget-accept
bindkey "ç" fzf-cd-widget
