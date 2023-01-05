{ pkgs, ... }: {
  imports = [ ./graphical.nix ];

  services.syncthing = {
    enable = true;
  };
}
