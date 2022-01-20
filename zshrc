# ~/.zshrc: user-specifc .zshrc file for zsh(1).

# zmodload zsh/zprof

[ -z "$PS1" ] && return

. ~/.shrc

() {
  for f; do
    if [[ -f $f && $f != *".zwc" ]]; then
      . "$f"
    fi
  done
  unset f
} ~/.zsh/functions/* \
	~/.zsh/configs{-pre,,-post}/**/*(N-.) \
	~/.zsh/completion.zsh \
  ~/.zshrc.local

command_exists() {
  (( $+commands[$1]))
}

function_exists() {
  (( $+functions[$1]))
}

autoload -U zmv
alias zcp='zmv -C'
alias zln='zmv -L'

if command_exists starship; then
  eval "$(starship init zsh)"
fi

if command_exists zoxide; then
  eval "$(zoxide init zsh)"
fi

# zprof

