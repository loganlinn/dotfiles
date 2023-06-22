{ config, lib, pkgs, ... }:

with lib;
{
  imports = [ ./aliases.nix ];

  programs.bash.initExtra = ''
    ${readFile ./which.sh}
  '';

  programs.zsh.initExtra = ''
    ${readFile ./which.sh}
  '';
}
