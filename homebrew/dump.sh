#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
brew bundle dump --file="$DIR/Brewfile.symlink" --force
