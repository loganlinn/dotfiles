{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./yubikey.nix
    ./titan-security-key.nix
  ];

  security.sudo.package = pkgs.sudo.override {withInsults = true;}; # do your worst.
}
