{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf (config.services.syncthing.enable && pkgs.stdenv.isLinux) {
    services.syncthing.tray.command = mkDefault "syncthingtray --wait";
    # Add syncthingtray PATH, which is useful for thigns like:
    #  --windowed, -w
    #    opens the tray menu as a regular window
    #  --webui
    #    instantly shows the web UI - meant for creating shortcut to web UI
    #  --trigger
    #    instantly shows the left-click tray menu - meant for creating a shortcut
    #  --wait
    #    wait until the system tray becomes available instead of showing an error message if the system tray is not available on s
    #    tart-up
    #  --single-instance
    #    does nothing if a tray icon is already shown
    #  --replace
    #    replaces a currently running instance
    home.sessionPath = [ "${config.services.syncthing.tray.package}/bin" ];
  };
}
