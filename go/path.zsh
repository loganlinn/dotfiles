export GOPATH="$HOME/go"
export PATH="$PATH:${GOPATH}/bin"

if ! test -d "${GOPATH}"; then
    if test -d "$HOME/.go"; then
        mv "$HOME/.go" "$GOPATH"
    else
        mkdir "${GOPATH}"
    fi
fi

if (( $+commands[brew] )) ; then
    export GOROOT="$(brew --prefix golang)/libexec"
    export PATH="$PATH:${GOROOT}/bin"
fi