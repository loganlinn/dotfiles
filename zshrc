# User profile for interactive zsh(1) shells.

# zmodload zsh/zprof
# export ANTIGEN_LOG=/tmp/antigen.log

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# extra files in ~/.zsh/configs/pre , ~/.zsh/configs , and ~/.zsh/configs/post
# these are loaded first, second, and third, respectively.
_load_settings() {
  _dir="$1"
  if [ -d "$_dir" ]; then
    if [ -d "$_dir/pre" ]; then
      for config in "$_dir"/pre/**/*~*.zwc(N-.); do
        . $config
      done
    fi

    for config in "$_dir"/**/*(N-.); do
      case "$config" in
        "$_dir"/(pre|post)/*|*.zwc)
          :
          ;;
        *)
          . $config
          ;;
      esac
    done

    if [ -d "$_dir/post" ]; then
      for config in "$_dir"/post/**/*~*.zwc(N-.); do
        . $config
      done
    fi
  fi
}

_load_settings "$HOME/.zsh/configs"

case $(uname -s) in
Darwin) [[ -f ~/.zshrc.darwin ]] && . ~/.zshrc.darwin ;;
Linux)  [[ -f ~/.zshrc.linux  ]] && . ~/.zshrc.linux  ;;
esac
[[ -f ~/.zshrc.local  ]] && . ~/.zshrc.local
[[ -f ~/.localrc      ]] && . ~/.localrc
[[ -f ~/.aliases      ]] && . ~/.aliases

# zprof
