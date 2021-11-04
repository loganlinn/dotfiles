#!/bin/sh

ENV=$HOME/.shrc

export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
	export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init --path)"
fi

if [ -r "$HOME/.profile.local" ]; then
	#shellcheck source=/dev/null
	. "$HOME/.profile.local"
fi
