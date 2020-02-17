#!/usr/bin/env bash

set -eu

info 'Running softwareupdate'
sudo softwareupdate -i -a

# Set OS X defaults
info 'Setting OSX defaults'
"$DOTFILES/macos/set-defaults.sh"

info 'Installing homebrew'
"$DOTFILES/homebrew/install.sh" 2>&1

# Upgrade homebrew
echo "› brew update"
brew update