#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")/.."

export DOTFILES="$(pwd -P)"

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
  printf "\r  [ ${BLUE}..${RESET} ] %s\n" "$@"
}

user () {
  printf "\r  [ ${YELLOW}??${RESET} ] %s\n" "$@"
}

success () {
  printf "\r  [ ${GREEN}OK${RESET} ] %s\n" "$@"
}

warning () {
  printf "\r  [ ${YELLOW}!!${RESET} ] %s\n" "$@"
}

fail () {
  printf "\r  [${RED}FAIL${RESET}] %s\n" "$@"
  exit 1
}
