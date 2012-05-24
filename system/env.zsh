#export EDITOR='mvim'
export EDITOR='vim'

if [[ $(uname -s) == "Linux" && "$TERM" == "xterm" ]]; then
  export TERM='xterm-256color'
fi
