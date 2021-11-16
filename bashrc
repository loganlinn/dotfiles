# ~/.bashrc: executed by bash(1) for non-login shells.
#shellcheck disable=SC1090

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

[ -f ~/.shrc ] && . ~/.shrc

[ -f ~/.bash_aliases ] && . ~/.bash_aliases

[ -f ~/.fzf.bash ] && . ~/.fzf.bash

[ -f ~/.bashrc.local ] && . ~/.bashrc.local

