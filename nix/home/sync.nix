{ pkgs, ... }: {
  imports = [ ./graphical.nix ];

  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      package = pkgs.syncthingtray;
    };
  };
}
