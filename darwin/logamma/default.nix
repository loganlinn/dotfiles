{
  self,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  packages = with pkgs; [
    nodejs
    yarn
    nodePackages.typescript-language-server
    awscli2
    mkcert
    clickhouse
    clickhouse-cli
  ];
in
{
  imports = [
    self.darwinModules.common
    self.darwinModules.home-manager
    ../modules/aerospace.nix
    ../modules/emacs.nix
  ];

  homebrew.enable = true;

  home-manager.users.logan =
    { options, config, ... }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.nix-colors
        self.homeModules.nixvim
        ../../nix/home/dev
        ../../nix/home/dev/nodejs.nix
        ../../nix/home/pretty.nix
        ../../nix/home/kitty
        ../../nix/home/doom
        ../../nix/modules/programs/nixvim
      ];

      programs.nixvim = {
        enable = true;
        defaultEditor = true;
      };

      programs.kitty.enable = true;

      home.packages = packages;

      home.stateVersion = "22.11";
    };

}
