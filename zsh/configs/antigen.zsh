# https://github.com/zsh-users/antigen/wiki/Configuration
export ANTIGEN=$HOME/antigen
export ADOTDIR=$HOME/.antigen
export ZSH=$ADOTDIR/bundles/robbyrussell/oh-my-zsh
export ZSH_CUSTOM=$HOME/.zsh
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1

# bootstrap
[[ -d $ANTIGEN ]] || git clone https://github.com/zsh-users/antigen.git "$ANTIGEN"
[[ -d $ZSH ]]     || git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"

source $ANTIGEN/antigen.zsh

antigen use oh-my-zsh
antigen bundles <<EOBUNDLES
    aws
    clvv/fasd
    colored-man-pages
    command-not-found
    direnv
    docker
    doctl
    emacs
    extract
    fzf
    git
    github
    gpg-agent
    gradle
    kubectl
    lein
    loganlinn/zzz.plugin.zsh
    mchav/with
    pierpo/fzf-docker
    pip
    safe-paste
    sirhc/okta.plugin.zs
    terraform
    urltools
    vi-mode
    web-search
    wfxr/forgit
    zsh-users/zaw
    zsh-users/zsh-autosuggestions 
    zsh-users/zsh-completions 
    zsh-users/zsh-history-substring-search 
    zsh-users/zsh-syntax-highlighting
    zsh_reload
EOBUNDLES
[[ -d ~/.jenv ]] && antigen bundle jenv
[[ -d ~/.pyenv ]] && antigen bundle pyenv
[[ -d ~/.rbenv ]] && antigen bundle rbenv
antigen bundle ~/.zsh/plugins/*(/) --no-local-clone
antigen theme "${ANTIGEN_THEME:-romkatv/powerlevel10k}"
antigen apply