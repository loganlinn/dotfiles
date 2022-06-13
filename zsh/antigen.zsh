# antigen.zsh
#

export ANTIGEN=$HOME/antigen
export ADOTDIR=$HOME/.antigen
export ZSH=$ADOTDIR/bundles/robbyrussell/oh-my-zsh
export ZSH_CUSTOM=${ZSH_CONFIG:-HOME/.zsh}

[[ -d $ANTIGEN ]]    || git clone https://github.com/zsh-users/antigen.git "$ANTIGEN"
[[ -d $ZSH ]]        || git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
[[ -d $ZSH_CUSTOM ]] || rcup -v zsh

source "$ANTIGEN/antigen.zsh"

antigen init "$ZSH_CUSTOM/antigenrc"
