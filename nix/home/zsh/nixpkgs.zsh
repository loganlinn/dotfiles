#!/usr/bin/env zsh

nixpkgs() {
    case $1 in
        ""|-h|--help)
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

nixpkgs-repl() {
  nix repl --expr '
    let pkgs = import <nixpkgs> {}; in
    builtins // pkgs.lib // { inherit pkgs; }'
}

nixpkgs-shell() {
  nix shell "${@/#/nixpkgs#}"
}

nixpkgs-build() {
  nix build "${@/#/nixpkgs#}"
}

nixpkgs-run() {
  nix run "nixpkgs#${1?}" "${@:2}"
}

nixpkgs-develop() {
    nix develop "${@::-1}" "nixpkgs#${@[-1]}"
}

nixpkgs-edit() {
    nix edit "${@::-1}" "nixpkgs#${@[-1]}"
}

if (($+functions[compdef])); then
  compdef nixpkgs=nix
fi
