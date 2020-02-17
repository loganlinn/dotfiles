if [ -d "$FZFHOME/shell" ]; then
    [[ $- == *i* ]] && source "$FZFHOME/shell/completion.zsh" 2> /dev/null
    source "$FZFHOME/shell/key-bindings.zsh"
fi