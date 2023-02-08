#!/usr/bin/env bash

[[ -z ${DEBUG:-} ]] || set -x

if [[ ! -v HOME_MANAGER_FLAKE ]]; then
    for HOME_MANAGER_FLAKE in \
        "${XDG_CONFIG_HOME:-$HOME/.config}/nixpkgs" \
        "${DOTFILES_DIR:-$HOME/.dotfiles}"; do
        ! [[ -e $HOME_MANAGER_FLAKE/flake.nix ]] || break
    done
fi

case ${1-} in
    metadata)
        nix flake metadata "$HOME_MANAGER_FLAKE" "$@"
        ;;

    # edit command that works for flake
    edit)
        editFlakeConfig
        ;;

    option)
        exec home-manager "$@"
        ;;

    -l | --list)
        nix eval "${1-}#homeConfigurations" \ --apply 'with builtins; x: concatStringsSep "\n" (attrNames x)'
        ;;

    *)
        # shellcheck disable=SC2086
        exec home-manager \
            --flake "$HOME_MANAGER_FLAKE" \
            --impure \
            -b backup."$(date +%s)" \
            "$@"
        ;;

esac
