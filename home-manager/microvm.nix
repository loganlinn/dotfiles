{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    self.homeModules.common
    ../nix/home/dev
    ../nix/home/nixvim
    ../nix/home/atuin.nix
    ../nix/home/tmux.nix
    ../nix/home/ssh.nix
    ../nix/home/pretty.nix
    ../nix/home/home-manager.nix
  ];

  programs.atuin.enable = true;
  programs.nixvim.enable = true;
  programs.nixvim.defaultEditor = true;
  programs.ssh.enable = true;

  home.username = "logan";
  home.homeDirectory = "/home/logan";
  home.stateVersion = "23.05";
}
