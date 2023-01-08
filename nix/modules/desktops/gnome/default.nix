{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.desktops.gnome;
in {
  options.modules.desktops.gnome = {
    enable = mkEnableOption "Enable gnome desktop";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    environment.systemPackages = with pkgs; [gnome.gnome-tweaks];
  };
}
