#!/usr/bin/env zsh

function nixpkgs() {
  case ${1=repl} in
    -h|--help)
      echo "Usage: nixpkgs <command> [options]"
      echo
      echo "COMMANDS:"
      print -l \
        ${(ok)commands[(I)nixpkgs-*]/nixpkgs-/  } \
        ${(ok)functions[(I)nixpkgs-*]/nixpkgs-/  } \
        | sort
      ;;
    *) nixpkgs-"$@" ;;
  esac
}

function nixpkgs-repl() {
  nix repl --expr 'let pkgs = import <nixpkgs> {}; in builtins // pkgs.lib // { inherit pkgs; inherit (pkgs) lib; }'
}

function nixpkgs-shell() {
  nix shell "${@/#/nixpkgs#}"
}

function nixpkgs-build() {
  nix build "${@/#/nixpkgs#}"
}

function nixpkgs-run() {
  nix run "nixpkgs#${1?}" "${@:2}"
}

function nixpkgs-develop() {
  nix develop "${@::-1}" "nixpkgs#${@[-1]}"
}

function nixpkgs-edit() {
  nix edit "${@::-1}" "nixpkgs#${@[-1]}"
}
