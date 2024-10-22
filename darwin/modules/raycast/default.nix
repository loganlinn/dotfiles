{
  config,
  lib,
  pkgs,
  ...
}:

{
  # homebrew.brews = ["raycast"];

  system.defaults."com.raycast.macos" = {
    "amplitudePulseAnalyticsTracker_nextHeartbeatDate" = "2120-12-31 00:00:00 +0000";
    "raycastAnonymousId" =
      let
        uuid = "${pkgs.libossp_uuid}/bin/uuid";
        command = "${uuid} -v4 -m | tr '[a-z]' '[A-Z]' | xargs echo -n > $out";
      in
      lib.readFile "${pkgs.runCommand "raycastAnonymousId" { } command}";
  };
}
