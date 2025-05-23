{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs.stdenv.targetPlatform) isLinux;
in {
  home.packages =
    [
      pkgs.kubelogin
    ]
    ++ (lib.optional isLinux pkgs.azure-cli);

  # otherwise it uses ~/.azure
  home.sessionVariables."AZURE_CONFIG_DIR" = "${config.xdg.configHome}/azure";
}
