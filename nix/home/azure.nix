{pkgs, ...}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  home.packages =
    if (!isDarwin)
    then [pkgs.azure-cli]
    else [];
}
