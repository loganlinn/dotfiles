#export EDITOR='mvim'
export EDITOR='vim'

if [[ $(uname -s) == "Linux" && "$TERM" == "xterm" ]]; then
	export TERM='xterm-256color'
fi

if [ -e $HOME/vimclojure/server/server.jar ]; then
	export VIMCLOJURE_SERVER_JAR=$HOME/vimclojure/server/server.jar
fi
