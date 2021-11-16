#
#                     oooo                           
#                     `888                           
#   oooooooo  .oooo.o  888 .oo.   oooo d8b  .ooooo.  
#  d'""7d8P  d88(  "8  888P"Y88b  `888""8P d88' `"Y8 
#    .d8P'   `"Y88b.   888   888   888     888       
#  .d8P'  .P o.  )88b  888   888   888     888   .o8 
# d8888888P  8""888P' o888o o888o d888b    `Y8bod8P' 
#

# zmodload zsh/zprof

# Load files
# ------------

() {
	while (( $# > 0 )); do
    [[ -f $1 && $1 != *".zwc" ]] && . "$1"
    shift
  done
} ~/.shrc \
  ~/.zsh/functions/* \
	~/.zsh/configs{-pre,,-post}/**/*(N-.) \
	~/.zsh/completion.zsh \
  ~/.zshrc.{${(L)OSTYPE//[0-9\.]/},local} \
  ~/.aliases{,.local}

# Setup prompt
# ------------

(( $+commands[starship] )) &&  eval "$(starship init zsh)"

# zprof
