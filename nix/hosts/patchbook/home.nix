{ pkgs, ... }:

{
  imports = [
    ../../common.nix
    ../../dev
    ../../fonts.nix
    ../../gh.nix
    ../../pretty.nix
    ../../zsh
  ];

  home.stateVersion = "22.11";
}
