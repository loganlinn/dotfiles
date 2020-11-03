# zmodload zsh/zprof

#------------------------------------------------------------------------------
# begin
#------------------------------------------------------------------------------

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#------------------------------------------------------------------------------
# variables
#------------------------------------------------------------------------------

export EDITOR=nvim
export DOTFILES=${DOTFILES:-"$HOME/.dotfiles"}
export PROJECTS=${PROJECTS:-"$HOME/code"}
export ANTIGEN=$HOME/antigen
export ADOTDIR=$HOME/.antigen
export ZSH=$ADOTDIR/bundles/robbyrussell/oh-my-zsh
export ZSH_CUSTOM=$HOME/.zsh-custom
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1

path=(/usr/local/{bin,sbin} $HOME/bin $HOME/.bin $HOME/.local/bin $HOME/go/bin $path)

# prefer gnu tools
if (( $+commands[brew] )); then
  path=($(brew --prefix)/opt/{{coreutils,gawk,gnu-indent,gnu-sed,gnu-tar,grep,make}/libexec/gnubin,curl/bin} $path)
fi

fpath=(~/.zsh/completions ~/.zsh/functions $fpath)

#------------------------------------------------------------------------------
# bootstrap
#------------------------------------------------------------------------------

[[ -d $ANTIGEN ]] || git clone https://github.com/zsh-users/antigen.git "$ANTIGEN"
[[ -d $ZSH ]]     || git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"

source $ANTIGEN/antigen.zsh

#------------------------------------------------------------------------------
# plugins
#------------------------------------------------------------------------------

antigen use oh-my-zsh

antigen bundle aws
antigen bundle command-not-found
antigen bundle direnv
antigen bundle docker
antigen bundle doctl
antigen bundle extract
antigen bundle fzf
antigen bundle git
antigen bundle github
antigen bundle gpg-agent
antigen bundle gradle
[[ -d ~/.jenv ]] && antigen bundle jenv
antigen bundle kubectl
antigen bundle lein
antigen bundle pip
[[ -d ~/.pyenv ]] && antigen bundle pyenv
[[ -d ~/.rbenv ]] && antigen bundle rbenv
antigen bundle safe-paste
antigen bundle terraform
antigen bundle urltools
antigen bundle vi-mode
antigen bundle wd
antigen bundle web-search
antigen bundle zsh_reload

antigen bundle zsh-users/zaw
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle loganlinn/zzz.plugin.zsh
antigen bundle clvv/fasd
antigen bundle mchav/with
antigen bundle pierpo/fzf-docker
#antigen bundle reconquest/shdoc
antigen bundle sirhc/okta.plugin.zsh
antigen bundle sirhc/op.plugin.zsh
antigen bundle wfxr/forgit

for plugin ($ZSH_CUSTOM/plugins/*(/)); do
  antigen bundle "$plugin"
done

antigen theme "${ANTIGEN_THEME:-romkatv/powerlevel10k}"

antigen apply

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
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
unfunction _load_settings

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.localrc ]] && source ~/.localrc
[[ -f ~/.aliases ]] && source ~/.aliases

#------------------------------------------------------------------------------
# end
#------------------------------------------------------------------------------

# zprof
