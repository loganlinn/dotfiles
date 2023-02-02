{ pkgs ? import <nixpkgs> { }, ... }:

''
  setopt ignore_eof

  exit_interactive() {
    ${pkgs.gum}/bin/gum confirm "Exit zsh?" && exit
  }

  zle -N exit_interactive

  bindkey '^D' exit_interactive
''
