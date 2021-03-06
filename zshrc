# zmodload zsh/zprof

() { local x; for x; do [[ ! -f $x ]] || [[ $x = *".zwc" ]] || source "$x"; done } \
  ~/.zsh/functions/* \
	~/.zsh/configs{-pre,,-post}/**/*(N-.) \
  ~/.zshrc."${(L)OSTYPE//[0-9\.]/}" \
  ~/.zshrc.local \
  ~/.aliases \
  ~/.aliases.local

eval "$(starship init zsh)"

# zprof
