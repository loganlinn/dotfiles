{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.raycast;
in
{
  options.modules.raycast = with lib.types; {
    enable = lib.mkEnableOption "raycast";
    # scriptCommands = lib.mkOption {
    #   type = attrsOf str;
    #   default = {};
    # };
  };
  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = lib.singleton (
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        xdg.configFile = {
          # TODO cfg.scriptCommands
        };
      }
    );

    # homebrew.brews = ["raycast"];

    # system.defaults."com.raycast.macos" = {
    #   "amplitudePulseAnalyticsTracker_nextHeartbeatDate" = "2120-12-31 00:00:00 +0000";
    #   "raycastAnonymousId" =
    #     let
    #       uuid = "${pkgs.libossp_uuid}/bin/uuid";
    #       command = "${uuid} -v4 -m | tr '[a-z]' '[A-Z]' | xargs echo -n > $out";
    #     in
    #     lib.readFile "${pkgs.runCommand "raycastAnonymousId" { } command}";
    # };
  };
}
