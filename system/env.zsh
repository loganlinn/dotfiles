export EDITOR='vim'

case "$(uname -s)" in
  'Linux')
    export PLATFORM='linux'
    ;;
  'Darwin')
    export PLATFORM='osx'
    ;;
esac

if [[ "$TERM" == "xterm" ]]; then
	export TERM='xterm-256color'
fi

export SHELL="$(command -v zsh)"
