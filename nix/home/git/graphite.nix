{ self', config, lib, pkgs, ... }:

{
  home.packages = [
    self'.packages.graphite-cli
  ];

  home.shellAliases."gtx" = "npx --package='@withgraphite/graphite-cli' -- gt";
}
