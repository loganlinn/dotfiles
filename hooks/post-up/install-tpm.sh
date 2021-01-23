#!/usr/bin/env bash

set -e
set -u pipefail
[[ "${TRACE:-}" ]] && set -x

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

TPM_ROOT=${TPM_ROOT:-$HOME/.tmux/plugins/tpm}
ensure_repo tmux-plugins/tpm "${TPM_ROOT}"
"${TPM_ROOT}/bin/install_plugins"
