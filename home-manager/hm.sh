#!/usr/bin/env bash

set -e
[[ -z ${DEBUG:-} ]] || set -x

function ensure_flake {
    if [[ -v FLAKE_URI ]]; then
        FLAKE_REF="${FLAKE_URI%#*}"
        FLAKE_ATTR="${FLAKE_URI#*#}"
    fi

    if [[ ! -v FLAKE_REF ]]; then
        local dir

        for dir in \
            "${DOTFILES_DIR:-$HOME/.dotfiles}" \
            "${XDG_CONFIG_HOME:-$HOME/.config}/nixpkgs"; do
            if [[ -e $dir/flake.nix ]]; then
                if [[ -v VERBOSE ]]; then
                    echo "using ${FLAKE_REF}"
                fi
                FLAKE_REF=$dir
                break
            fi
            if [[ ! -v FLAKE_REF ]]; then
                echo "flake not found!" >&2
                return 1
            fi
        done
    fi

    if [[ ! -v FLAKE_ATTR ]]; then
        FLAKE_ATTR=$(printf '"%s@%s"' "$USER" "$(hostname -s)")
    fi

    if [[ ! -v FLAKE_URI ]]; then
        FLAKE_URI="${FLAKE_REF?}#${FLAKE_ATTR?}"
    fi

}

function hm_option() {
    # ensure_flake

    # local args=("$@")

    # if [[ -v VERBOSE ]]; then
    #     args+=(--show-trace)
    # fi

    # local modulesExpr='let flakeModule = builtins.getFlake (builtins.toString ./.); in
    #     flakeModule.legacyPackages.${currentSystem}.homeConfigurations.'"$FLAKE_ATTR"''

    # (
    #     cd "$FLAKE_REF" &&
    #         nixos-option \
    #             --options_expr "($modulesExpr).options" \
    #             --config_expr "($modulesExpr).config" \
    #             "${args[@]}"
    # )

    home-manager option "$@"
}

function hm_update() {
    ensure_flake
    if [[ $# -eq 0 ]]; then
        echo "Updating all input flakes..."
        nix flake update --impure "$FLAKE_REF"
    else
        echo "Updating input flakes: $*"
        nix flake lock --impure "${@/#/--update-input }" "$FLAKE_REF"
    fi
}

function hm_list() {
    ensure_flake

    local expr='with builtins; x: concatStringsSep "\n" (attrNames x)'
    local names
    # shellcheck disable=SC2005
    names=$(nix eval "${FLAKE_REF}#homeConfigurations" --apply "$expr")
    # remove outer quotes
    names="${names#\"}"
    names="${names%\"}"
    echo -e "$names"
}

function hm_command() {
    ensure_flake

    home-manager \
        --flake "$FLAKE_REF" \
        --impure \
        -b backup \
        "$@"
}

COMMAND=""
ARGS=()

while [[ $# -gt 0 ]]; do
    case "${1-}" in
        # special commands
        metadata | show | list | update | option | gc)
            COMMAND=$1
            shift
            ;;
        --flake)
            [[ $# -gt 1 ]] || {
                echo "missing argument after $1" >&2
                exit 1
            }
            FLAKE_REF="${2%#*}"
            FLAKE_ATTR="${2#*#}"
            shift 2
            ;;
        -v | --verbose)
            VERBOSE=${1}
            shift
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

case $COMMAND in
    metadata)
        ensure_flake
        nix flake metadata "$FLAKE_REF" "${ARGS[@]}"
        ;;

    show)
        ensure_flake
        nix flake show "$FLAKE_REF" "${ARGS[@]}"
        ;;

    list)
        [[ ${#ARGS[@]} -eq 0 ]] || {
            echo "unexpected arguments: ${ARGS[*]}" >&2
            exit 1
        }
        hm_list
        ;;

    update)
        hm_update "${ARGS[@]}"
        ;;

    option)
        hm_option "${ARGS[@]}"
        ;;

    gc)
        echo "Optimizing nix store"
        nix-store --optimise -vv

        echo "Collecting generations"
        nix-collect-garbage --delete-old
        ;;

    # switch | build | instantiate | generations | remove-generations | expire-generations | packages | news)
    *)
        hm_command "${ARGS[@]}"
        ;;
esac

exit 0
