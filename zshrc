# ~/.zshrc: user-specifc .zshrc file for zsh(1).

# zmodload zsh/zprof

[ -z "$PS1" ] && return

. ~/.shrc

() {
  for i; do
    if [[ -f $i && $i != *".zwc" ]]; then
      . "$i"
    fi
  done
  unset i
} ~/.zsh/functions/* \
	~/.zsh/configs{-pre,,-post}/**/*(N-.) \
	~/.zsh/completion.zsh \
  ~/.zshrc.local

if autoload -U zmv; then
  alias zcp='zmv -C'
  alias zln='zmv -L'
fi

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# zprof
