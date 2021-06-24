# zmodload zsh/zprof

() {
	local x 
	for x
	do [[ ! -f $x ]] || [[ $x = *".zwc" ]] || source "$x" || true
	done
} ~/.zsh/functions/* \
	~/.zsh/configs-pre/**/*(N-.) \
	~/.zsh/configs/**/*(N-.) \
	~/.zsh/configs-post/**/*(N-.) \
  ~/.zshrc."${(L)OSTYPE//[0-9\.]/}" \
  ~/.zshrc.local \
  ~/.aliases

# zprof
