{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.my.gaming;
in {
  options.my.gaming = {
    enable = mkEnableOption "gaming";
  };

  config = mkIf cfg.enable {
    programs.gamemode.enable = true;
    programs.gamemode.settings = {
      general = {
        softrealtime = "auto";
        renice = 10;
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    environment.systemPackages = with pkgs; [
      lutris
    ];
  };
}
