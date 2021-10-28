#!/usr/bin/env bash

TPM_ROOT=${TPM_ROOT:-$HOME/.tmux/plugins/tpm}

if ! [[ -d $TPM_ROOT ]]; then
	git clone https://github.com/tmux-plugins/tpm.git "${TPM_ROOT}"
	"${TPM_ROOT}/bin/install_plugins"
fi
