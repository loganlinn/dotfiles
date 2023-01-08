{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./dev.nix
    ./fonts.nix
    ./gh.nix
    ./pretty.nix
    ./zsh.nix
  ];

  home.stateVersion = "22.11";
}
