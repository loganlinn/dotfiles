{
  self,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    self.darwinModules.common
    self.darwinModules.home-manager
    ../modules/homebrew.nix
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
        ../../nix/home/pretty.nix
        ../../nix/home/kitty
      ];

      programs.kitty.enable = true;

      home.stateVersion = "22.11";
    };

}
