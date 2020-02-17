if [ -d "/usr/local/opt/fzf" ]; then
    export FZFHOME="/usr/local/opt/fzf"
else
    export FZFHOME="$HOME/.fzf"
fi

export PATH="$FZFHOME/bin:$PATH"