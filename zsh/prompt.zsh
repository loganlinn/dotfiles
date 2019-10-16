autoload colors && colors
# cheers, @ehrenmurdick
# http://github.com/ehrenmurdick/config/blob/master/zsh/prompt.zsh

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  st=$($git status 2>/dev/null | tail -n 1)
  gpi=$(git_prompt_info) || return
  if [[ $st == "" ]] || [[ "$st" =~ ^nothing ]]
  then
    echo "on %{$fg_bold[green]%}${gpi}%{$reset_color%}"
  else
    echo "on %{$fg_bold[red]%}${gpi}%{$reset_color%}"
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo "${ref#refs/heads/}"
}

unpushed () {
  $git cherry -v @{upstream} 2>/dev/null
}

need_push () {
  if [[ $(unpushed) == "" ]]
  then
    echo " "
  else
    echo " with %{$fg_bold[magenta]%}unpushed%{$reset_color%} "
  fi
}

hostname_prompt(){
  echo "%{$fg_bold[yellow]%}$(hostname -s)%{$reset_color%}"
}

directory_name(){
  echo "%{$fg_bold[cyan]%}%1/%\/%{$reset_color%}"
}

virtualenv_name() {
  if ! [[ -z $VIRTUAL_ENV ]]; then
    echo "\n%{$fg_bold[white]%}($(basename $VIRTUAL_ENV))%{$reset_color%}"
  fi
}

battery_status() {
  if test ! "$(uname)" = "Darwin"
  then
    exit 0
  fi

  if [[ $(sysctl -n hw.model) == *"Book"* ]]
  then
    $ZSH/bin/battery-status
  fi
}

export VIRTUAL_ENV_DISABLE_PROMPT=1
export PROMPT=$'$(virtualenv_name)\n$(hostname_prompt) in $(directory_name) $(git_dirty)$(need_push)\n› '

set_prompt () {
  prefix='%{'$'\e[1A''%}' # one line up
  suffix='%{'$'\e[1B''%}' # one line down
  export RPROMPT="$prefix%{$fg_bold[cyan]%}%W %D{%L:%M:%S}%{$reset_color%}$suffix"
}

precmd() {
  title "zsh" "%m" "%55<...<%~"
  set_prompt
}
