export EDITOR='vim'

case "$(uname -s)" in
  'Linux')
    export PLATFORM='linux'
    ;;
  'Darwin')
    export PLATFORM='osx'
    ;;
esac

if [[ "$PLATFORM" == "linux" && "$TERM" == "xterm" ]]; then
	export TERM='xterm-256color'
fi
