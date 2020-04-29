#!/usr/bin/env bash

set -eu

case "$(uname -s)" in
  'Linux')
    export PLATFORM='linux'
    ;;
  'Darwin')
    export PLATFORM='osx'
    ;;
esac

cd "$(dirname "$0")/.."

DOTFILES="$(pwd -P)"

# Only use colors if connected to a terminal
if [ -t 1 ]; then
  RED=$(printf '\033[31m')
  GREEN=$(printf '\033[32m')
  YELLOW=$(printf '\033[33m')
  BLUE=$(printf '\033[34m')
  BOLD=$(printf '\033[1m')
  RESET=$(printf '\033[m')
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  RESET=""
fi

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

info () {
  echo -e "\r  [ ${BLUE}..${RESET} ] $*\n"
}

user () {
  echo -e "\r  [ ${YELLOW}??${RESET} ] $*\n"
}

success () {
  echo -e "\r  [ ${GREEN}OK${RESET} ] $*\n"
}

warning () {
  echo -e "\r  [ ${YELLOW}!!${RESET} ] $*\n"
}

fail () {
  echo -e "\r  [${RED}FAIL${RESET}] $*\n"
  exit 1
}

export DOTFILES
