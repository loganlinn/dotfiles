# ensure ~/.profile is sourced
if [ -z "$ENV" ] && [ -n "$PATH" ]; then
  case $- in
    *l*) ;;
    *) if [ -f ~/.profile ]; then . ~/.profile >/dev/null; fi ;;
  esac
fi

if [[ -e ~/.zshenv.local ]]; then . ~/.zshenv.local; fi
