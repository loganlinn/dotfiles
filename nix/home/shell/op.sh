op() {
    # for commands that require auth, signin
    if [[ " $*" != *" --help" ]]; then
        case " $* " in
            *" account get "* | \
                *" document "* | \
                *" events-api "* | \
                *" group "* | \
                *" item "* | \
                *" plugin init "* | \
                *" user "* | \
                *" vault "* | \
                *" whoami " | \
                *" run "* | \
                *" read "* | \
                *" inject "*)
                command op whoami >/dev/null 2>&1 || eval "$(command op signin)"
                ;;
        esac
    fi

    command op "$@"
}

# shellcheck disable=1090
if [[ -f ~/.config/op/plugins.sh ]]; then
    source ~/.config/op/plugins.sh
fi
