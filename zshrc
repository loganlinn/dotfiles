# zmodload zsh/zprof

() {
  local x
  for x
  do [[ ! -f $x ]] || [[ $x = *".zwc" ]] || . "$x"
  done
} ~/.zsh/functions/* \
	~/.zsh/configs{-pre,,-post}/**/*(N-.) \
  ~/.zshrc."${(L)OSTYPE//[0-9\.]/}" \
  ~/.zshrc.local \
  ~/.aliases

eval "$(starship init zsh)"

# zprof
