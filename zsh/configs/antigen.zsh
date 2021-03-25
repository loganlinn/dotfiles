# https://github.com/zsh-users/antigen/wiki/Configuration
export ANTIGEN=$HOME/antigen
export ADOTDIR=$HOME/.antigen
export ZSH=$ADOTDIR/bundles/robbyrussell/oh-my-zsh
export ZSH_CUSTOM=$HOME/.zsh

[[ -d $ANTIGEN ]] || git clone https://github.com/zsh-users/antigen.git "$ANTIGEN"
[[ -d $ZSH ]]     || git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"

source $ANTIGEN/antigen.zsh

antigen use oh-my-zsh

# https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
antigen bundles <<EOBUNDLES
    aws
    cargo
    clvv/fasd
    colored-man-pages
    command-not-found
    direnv
    docker
    doctl
    emacs
    extract
    fasd
    fzf
    genpass
    git
    github
    gitignore
    gpg-agent
    gradle
    man
    kubectl
    lein
    loganlinn/zzz.plugin.zsh
    mchav/with
    pierpo/fzf-docker
    pip
    safe-paste
    sirhc/okta.plugin.zsh
    sirhc/op.plugin.zsh
    ssh-agent
    terraform
    urltools
    vi-mode
    web-search
    wfxr/forgit
    zsh-interactive-cd
    zsh-users/zaw
    zsh-users/zsh-autosuggestions 
    zsh-users/zsh-completions 
    zsh-users/zsh-history-substring-search 
    zsh-users/zsh-syntax-highlighting
    zsh_reload
EOBUNDLES

[[ -d ~/.jenv ]]  && antigen bundle jenv
[[ -d ~/.pyenv ]] && antigen bundle pyenv
[[ -d ~/.rbenv ]] && antigen bundle rbenv

for bundle in ~/.zsh/plugins/*(/)
do
  antigen bundle "${bundle}" --no-local-clone
done

antigen theme "${ANTIGEN_THEME:-romkatv/powerlevel10k}"

antigen apply

# configure bundles

export FORGIT_FZF_DEFAULT_OPTS='--preview-window=right:80%'
export FORGIT_ADD_FZF_OPTS='--ansi'

export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_USE_ASYNC=1


