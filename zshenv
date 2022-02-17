# ~/.zshenv
#
# NOTE: The various profile/rc/login files all get sourced *after* this file,
#       so any variables set here can/will be overwritten.

# ensure ~/.profile is sourced
if [[ -z "$ENV" && -n "$PATH" ]]; then
  case $- in
    *l*) ;;
    *) ! [[ -e ~/.profile ]] || . ~/.profile ;;
  esac
fi

# # Check $SHLVL to ensure that this only happens the first time the shell is started.
# if [[ $SHLVL == 1 && ! -o LOGIN ]]; then
#   source ~/.zpath
# fi

! [[ -e ~/.zshenv.local ]] || . ~/.zshenv.local
