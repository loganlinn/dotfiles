{ config
, pkgs
, self
, ...
}:

{

  imports = [
    ./readline.nix
  ];

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    htop = {
      enable = true;
      settings.color_scheme = 1;
    };
  };
}
