#!/usr/bin/env bash

[[ -n ${DEBUG-} ]] && set -x

hash kubectl jq entr || exit 127

_kubebinary=${KUBEBAR_BINARY:-kubectl}
_kubeconfig="${KUBEBAR_KUBECONFIG-${KUBECONFIG-$HOME/.kube/config}}"
# shellcheck disable=SC2016
_format=${KUBEBAR_FORMAT-'$KUBE_CURRENT_CONTEXT/$KUBE_CURRENT_NAMESPACE'}
_escape=${KUBEBAR_ESCAPE-'@'}
_watch=${KUBEBAR_WATCH-true}

while [[ $# -gt 0 ]]; do
  case ${1-} in
    -h | --help)
      echo "usage: $(basename "$0") [-h] [-w]"
      exit 0
      ;;
    --no-watch | --watch=false)
      _watch=false
      shift
      ;;

    -w | --watch | --watch=true)
      _watch=true
      shift
      ;;
    -E | --escape)
      _escape=${2-}
      shift 2
      ;;
    -F | --format)
      _format=${2?}
      shift 2
      ;;
    --kubeconfig)
      _kubeconfig=${2?}
      shift 2
      ;;
    -*)
      echo "unrecoginized flag: $1" >&2
      exit 1
      ;;
    *) break ;;
  esac
done

_kubectl() {
  "$_kubebinary" "$@"
}

_current_context() {
  _kubectl config current-context
}

_current_namespace() {
  _kubectl config view -o json |
    jq -r '.["current-context"] as $current | .contexts[] | select(.name == $current) | .context.namespace'
}

_print() {
  tr "$_escape" '$' <<<"$_format" |
    env \
      KUBE_CURRENT_CONTEXT="$(_current_context)" \
      KUBE_CURRENT_NAMESPACE="$(_current_namespace)" \
      envsubst
}

if [[ $_watch == true ]]; then
  exec echo "$_kubeconfig" | entr -n "$0" --no-watch
else
  _print
fi
