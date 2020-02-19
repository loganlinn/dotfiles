# vi: set ft=zsh :
exit() {
  if [[ -z $TMUX ]]; then
    builtin exit
    return
  fi

  panes=$(tmux list-panes | wc -l)
  wins=$(tmux list-windows | wc -l) 
  count=$(($panes + $wins - 1))
  if [ $count -eq 1 ]; then
    tmux detach
  else
    builtin exit
  fi
}
