#!/bin/sh
if [ "$PLATFORM" != "osx" ]; then exit; fi

if [ ! -x "$(command -v brew)" ]; then
  echo "› installing homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi