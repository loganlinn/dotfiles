{ self', config, lib, pkgs, ... }:

{
  home.packages = [
    pkgs.graphite-cli
  ];

  home.shellAliases."gtx" = "npx --package='@withgraphite/graphite-cli' -- gt";

  home.sessionVariables = {
    GRAPHITE_DISABLE_TELEMETRY = "1";
  };
}
