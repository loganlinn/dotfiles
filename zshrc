# zmodload zsh/zprof

# Load files
() {
	while (( $# > 0 )); do
    if [[ -f $1 ]] && ! [[ $1 = *".zwc" ]]; then
      source "$1"
    fi
    shift
  done
} ~/.shrc \
  ~/.zsh/functions/* \
	~/.zsh/configs{-pre,,-post}/**/*(N-.) \
	~/.zsh/completion.zsh \
  ~/.zshrc."${(L)OSTYPE//[0-9\.]/}" \
  ~/.zshrc.local \
  ~/.aliases \
  ~/.aliases.local

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# zprof
