#!/usr/bin/env sh

if ! git -C ~/.emacs.d rev-parse 2>/dev/null; then
  if [ -d ~/.emacs.d ]; then
    mv -v -b ~/.emacs.d ~/.emacs.d~
  fi
	echo "Installing Spacemacs..." >&2
	git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
fi
