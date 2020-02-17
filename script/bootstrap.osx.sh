#!/usr/bin/env bash

if test ! "$(uname)" = "Darwin"; then
  >&2 echo "Wrong platform"
  exit 0
fi


set -eu

info 'Running softwareupdate'
sudo softwareupdate -i -a

# Set OS X defaults
"$DOTFILES_ROOT/macos/set-defaults.sh"

# Install homebrew
"$DOTFILES_ROOT/homebrew/install.sh" 2>&1

# Upgrade homebrew
echo "› brew update"
brew update