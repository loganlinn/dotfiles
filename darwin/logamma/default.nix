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
    ../modules/aerospace.nix
    ../modules/emacs.nix
  ];

  homebrew = {
    # onActivation.cleanup = "zap";
    casks = [
      # "1password"
      "1password-cli"
    ];
    brews = [ ];
  };

  home-manager.users.logan =
    { options, config, ... }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.nix-colors
        inputs.nixvim.homeManagerModules.nixvim
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

      home.packages = with pkgs; [
        aws-vault
        awscli2
        mkcert
        nodePackages.typescript-language-server
        nodejs
        yarn
      ];

      home.stateVersion = "22.11";
    };

  environment.systemPackages = with pkgs; [
    clickhouse
    clickhouse-cli
  ];
}
