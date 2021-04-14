#!/usr/bin/env bash

# Usage: dotenv [<dotenv>]
#
# Loads a ".env" file into the current environment
#
dotenv() {
  local path=${1:-}
  if [[ -z $path ]]; then
    path=$PWD/.env
  elif [[ -d $path ]]; then
    path=$path/.env
  fi
  if ! [[ -f $path ]]; then
    >&2 echo ".env at $path not found"
    return 1
  fi
  eval "$(/usr/local/bin/direnv dotenv bash "$@")"
}

# Usage: dotenv_if_exists [<filename>]
#
# Loads a ".env" file into the current environment, but only if it exists.
#
dotenv_if_exists() {
  local path=${1:-}
  if [[ -z $path ]]; then
    path=$PWD/.env
  elif [[ -d $path ]]; then
    path=$path/.env
  fi
  if ! [[ -f $path ]]; then
    return
  fi
  eval "$(/usr/local/bin/direnv  dotenv bash "$@")"
}
