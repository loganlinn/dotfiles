[[ -z ${DEBUG:-} ]] || set -x

HM_CONFIG_FLAKE=${HM_CONFIG_FLAKE:-$HOME/.dotfiles}

function editFlakeConfig() {
    # shellcheck disable=2086
    exec ${EDITOR?} "$HM_CONFIG_FLAKE"
}

function runHomeManager() {
    local flakeArg=$HM_CONFIG_FLAKE
    local extraArgs=("$@")

    # HM_CONFIG_NAME env can be name of a homeConfiguration.
    #
    # If unset, we use home-manager's default behavior, i.e. $USER@$HOSTNAME.
    if [[ -n ${HM_CONFIG_NAME:-} ]]; then
        flakeArg="${flakeArg%%#*}#\"$HM_CONFIG_NAME\""
    fi

    # TODO configure this via inputs.nixpkgs.config.allowUnfree instead...
    if [[ ${NIXPKGS_ALLOW_UNFREE-1} = 1 ]]; then
        extraArgs+=(--impure)
    fi

    # backup suffix
    extraArgs+=(-b backup."$(date +%s)")

    # shellcheck disable=SC2086
    exec home-manager --flake "$flakeArg" "${extraArgs[@]}"
}

case ${1-} in
    metadata)
        nix flake metadata "$HM_CONFIG_FLAKE" "$@"
        ;;

    # edit command that works for flake
    edit)
        editFlakeConfig
        ;;

    *)
        runHomeManager "$@"
        ;;

esac
