{
  self',
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.graphite-cli
  ];

  home.shellAliases."gtx" = "npx --package='@withgraphite/graphite-cli' -- gt";

  home.sessionVariables = {
    GRAPHITE_DISABLE_TELEMETRY = "1";
  };

  programs.git.aliases = {
    stack = "!gt stack";
    upstack = "!gt upstack";
    us = "!gt upstack";
    downstack = "!gt downstack";
    ds = "!gt downstack";
    b = "!gt branch";
    l = "!gt log";
  };
}
