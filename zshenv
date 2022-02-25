# ~/.zshenv

#if [ -z "$ENV" ] && [ -n "$PATH" ]; then
if [ -n "$PATH" ]; then
  case $- in
    *l*) ;;
    *) if [ -f ~/.profile ]; then . ~/.profile; fi ;;
  esac
fi

if [[ -e ~/.zshenv.local ]]; then . ~/.zshenv.local; fi
