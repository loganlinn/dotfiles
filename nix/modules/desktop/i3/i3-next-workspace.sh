#!/usr/bin/env bash

set -eo pipefail

hash jq || exit 127

usage() {
    echo "usage: $(basename "$0") [-h|--help] <focus|move|carry>"
}

next_workspace() {
    i3-msg -t get_workspaces | jq -r '
        (.[] | select(.focused)) as $focused
        | map(select(.output == $focused.output and .num >= $focused.num))
        | max_by(.num)
        | "number \(.num + 1)"'
}

if [[ $# -eq 0 ]]; then
    echo "missing operand" >&2
    usage >&2
    exit 1
fi

command=

case "${1-}" in
    -h | --help)
        usage
        exit 0
        ;;
    focus)
        command="workspace $(next_workspace)"
        ;;
    move)
        command="move container to workspace $(next_workspace)"
        ;;
    carry)
        ws=$(next_workspace)
        command="move container to workspace $ws, workspace $ws"
        ;;
esac

if [[ -z $command ]]; then
    echo "unknown command '${1-}'" >&2
    usage >&2
    exit 1
fi

i3-msg "$command"
