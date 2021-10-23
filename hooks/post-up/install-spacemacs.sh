#!/usr/bin/env sh

if ! git -C ~/.emacs.d rev-parse 2>/dev/null; then
	echo "Installing spacemacs..."
	git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
fi
