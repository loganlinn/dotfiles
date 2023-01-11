{ lib, pkgs, ... }:

with lib;

''
setopt ignore_eof

exit_interactive() {
  ${getExe pkgs.gum} confirm "Exit zsh?" && exit
}

zle -N exit_interactive

bindkey '^D' exit_interactive
''
