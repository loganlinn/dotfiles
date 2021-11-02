#!/bin/sh

ENV=$HOME/.shrc

if [ -r "$HOME/.profile.local" ]; then
  #shellcheck source=/dev/null
  . "$HOME/.profile.local"
fi
