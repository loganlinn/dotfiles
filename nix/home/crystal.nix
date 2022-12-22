{pkgs, ...}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  home.packages = if (!isDarwin) then [
    pkgs.crystal
    pkgs.icr # crystal repl
    pkgs.shards # package-manager
  ] else [];
}
