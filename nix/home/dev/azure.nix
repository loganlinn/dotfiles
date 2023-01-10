{
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in {
  home.packages =
    [
      pkgs.kubelogin
    ]
    ++ (lib.optional isLinux pkgs.azure-cli);
}
