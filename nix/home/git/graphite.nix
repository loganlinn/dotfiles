{ self', config, lib, pkgs, ... }:

{
  home.packages = [
    pkgs.graphite-cli
  ];

  home.shellAliases."gtx" = "npx --package='@withgraphite/graphite-cli' -- gt";
}
