{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
