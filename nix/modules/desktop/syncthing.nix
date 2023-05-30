{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./tray.nix
  ];

  config = {
    services.syncthing = {
      enable = true;
      tray = {
        enable = true;
        package = pkgs.syncthingtray.override {
          webviewSupport = true;
          jsSupport = true;
          plasmoidSupport = false;
          kioPluginSupport = false;
        };
        command = "syncthingtray --wait";
      };
    };
  };
}
