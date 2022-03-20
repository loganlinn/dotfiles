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

#: https://starship.rs/guide/#%F0%9F%9A%80-installation
if command_exists starship; then
  eval "$(starship init zsh)"
fi

#: https://github.com/halcyon/asdf-java#java_home
if command_exists zoxide; then
  eval "$(zoxide init zsh)"
fi

#: https://github.com/halcyon/asdf-java#java_home
if [[ -e ~/.asdf/plugins/java/set-java-home.zsh ]]; then
  source ~/.asdf/plugins/java/set-java-home.zsh
fi

# zprof

