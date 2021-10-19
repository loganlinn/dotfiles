#!/bin/sh

ENV=$HOME/.shrc

export NPM_TOKEN

if [ -r "$HOME/.profile.local" ]; then
  #shellcheck source=/dev/null
  . "$HOME/.profile.local"
fi
