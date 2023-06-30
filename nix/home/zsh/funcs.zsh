#!/usr/bin/env zsh

function zman {
  PAGER="less -g -I -s '+/^       "$1"'" man zshall;
}

#
# nixpkgs helpers
#
nixpkgs() {
    case $1 in
        ""|-h|--help)
            echo "Usage: nixpkgs <command> [options]"
            echo
            echo "COMMANDS:"
            printf ' %s\n' \
                ${(ok)commands[(I)nixpkgs-*]/nixpkgs-/  } \
                ${(ok)functions[(I)nixpkgs-*]/nixpkgs-/  } \
                | sort
            ;;
        *)
            nixpkgs-"${@:1}" ;;
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
  nix run "nixpkgs#${1?}" "${@:1}"
}

nixpkgs-develop() {
    nix develop "${@::-1}" "nixpkgs#${@[-1]}"
}

nixpkgs-edit() {
    nix edit "${@::-1}" "nixpkgs#${@[-1]}"
}

nixpkgs-eval() {
    nix eval "${@::-1}" "nixpkgs#${@[-1]}"
}


# An rsync that respects gitignore
rcp() {
  # -a = -rlptgoD
  #   -r = recursive
  #   -l = copy symlinks as symlinks
  #   -p = preserve permissions
  #   -t = preserve mtimes
  #   -g = preserve owning group
  #   -o = preserve owner
  # -z = use compression
  # -P = show progress on transferred file
  # -J = don't touch mtimes on symlinks (always errors)
  rsync -azPJ \
    --include=.git/ \
    --filter=':- .gitignore' \
    --filter=":- $XDG_CONFIG_HOME/git/ignore" \
    "$@"
}; compdef rcp=rsync
alias rcpd='rcp --delete --delete-after'
alias rcpu='rcp --chmod=go='
alias rcpdu='rcpd --chmod=go='
