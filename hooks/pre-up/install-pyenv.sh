#!/usr/bin/env bash

set -e
set -u pipefail
[[ "${TRACE:-}" ]] && set -x

PYENV_ROOT=${PYENV_ROOT:-${HOME}/.pyenv}

ensure_repo() {
  local org_repo=$1
  local clone_dir=$2

  if [[ -d "${clone_dir}" ]]; then
    echo "exists ${clone_dir}"
  else
    echo "clone ${clone_dir}" >&2
    git clone --depth 1 "https://github.com/${org_repo}.git" "${clone_dir}" 
  fi
}

ensure_repo "pyenv/pyenv"            "${PYENV_ROOT}"
ensure_repo "pyenv/pyenv-doctor"     "${PYENV_ROOT}/plugins/pyenv-doctor"
ensure_repo "pyenv/pyenv-installer"  "${PYENV_ROOT}/plugins/pyenv-installer"
ensure_repo "pyenv/pyenv-update"     "${PYENV_ROOT}/plugins/pyenv-update"
ensure_repo "pyenv/pyenv-virtualenv" "${PYENV_ROOT}/plugins/pyenv-virtualenv"
ensure_repo "pyenv/pyenv-which-ext"  "${PYENV_ROOT}/plugins/pyenv-which-ext"
