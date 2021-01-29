#!/usr/bin/env bash

set -eu pipefail

[[ "${TRACE:-}" ]] && set -x

TPM_ROOT=${TPM_ROOT:-$HOME/.tmux/plugins/tpm}

[[ -d $TPM_ROOT ]] || git clone git@github.com:tmux-plugins/tpm.git "${TPM_ROOT}"

"${TPM_ROOT}/bin/install_plugins" > /dev/null
