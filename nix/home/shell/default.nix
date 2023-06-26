{ config, lib, pkgs, ... }:

with lib;

let

  # common init for bash + zsh
  initExtra = ''
    ${readFile ./which.sh}

    ${readFile ./op.sh}

    source ${./../../../bin/src-get}
    # eval "$(src init -)"
  '';

in
{
  imports = [ ./aliases.nix ];

  programs.bash.initExtra = ''
    ${initExtra}
  '';

  programs.zsh.initExtra = ''
    ${initExtra}
  '';
}