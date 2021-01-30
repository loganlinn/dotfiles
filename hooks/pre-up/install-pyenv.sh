#!/usr/bin/env bash

set -e
set -u pipefail
[[ "${TRACE:-}" ]] && set -x

PYENV_ROOT=${PYENV_ROOT:-${HOME}/.pyenv}

ensure-repo() {
  local repository=$1
  local directory=$2

  [[ -d $directory ]] && return
  if [[ $repository != *"://"* ]]; then
    repository="git@github.com:${repository}.git"
  fi
  git clone "${repository}" "${directory}" 
}

ensure-repo "pyenv/pyenv"            "${PYENV_ROOT}"
ensure-repo "pyenv/pyenv-doctor"     "${PYENV_ROOT}/plugins/pyenv-doctor"
ensure-repo "pyenv/pyenv-installer"  "${PYENV_ROOT}/plugins/pyenv-installer"
ensure-repo "pyenv/pyenv-update"     "${PYENV_ROOT}/plugins/pyenv-update"
ensure-repo "pyenv/pyenv-virtualenv" "${PYENV_ROOT}/plugins/pyenv-virtualenv"
ensure-repo "pyenv/pyenv-which-ext"  "${PYENV_ROOT}/plugins/pyenv-which-ext"
