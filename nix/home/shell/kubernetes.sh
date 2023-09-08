#!/usr/bin/env bash

kzf() {
  #shellcheck disable=SC2086
  kubectl get "$@" --no-headers -o custom-columns=":metadata.name" |
    fzf --exit-0 --header "$*"
}

alias kno="kzf nodes"
alias kcm="kzf configmaps"
alias kns="kzf namespaces"
alias kpo="kzf pods"
alias ksvc="kzf services"
alias kpvc="kzf persistentvolumeclaims"
alias kpv="kzf persistentvolumes"
alias kdeploy="kzf deployments"
alias kds="kzf daemonsets"
alias krs="kzf replicasets"
alias ksts="kzf statefulsets"
alias kcrd="kzf customresourcedefinitions"
alias kjobs="kzf jobs"
alias kcj="kzf cronjobs"
