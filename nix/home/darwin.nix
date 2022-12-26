{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./dev.nix
    ./fonts.nix
    ./gh.nix
    ./neovim.nix
    ./pretty.nix
    ./zsh.nix
  ];

  home.stateVersion = "22.11";
}
