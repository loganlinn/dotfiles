#!/usr/bin/env sh

if [ -x "$HOME/.pyenv/bin/pyenv" ]; then
  #export PYENV_ROOT="$HOME/.pyenv"
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi
