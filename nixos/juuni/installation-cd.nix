#
#    nix run github:nix-community/nixos-generators -- -f iso -c path/to/installation-cd.nix
#

{ config, pkgs, ... }:

let
  nixos-hardware = builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; };
in {
  imports = [
    "${pkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    "${pkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    "${nixos-hardware}/common/cpu/intel"
    "${nixos-hardware}/common/pc/ssd"
  ];

  hardware.enableRedistributableFirmware = true; # perhaps not necessary

  hardware.graphics.enable = true;

  boot.supportedFilesystems = [ "btrfs" ];

  users.users.root.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsEQb9/YUta3lDDKsSsaf515h850CRZEcRg7X0WPGDa"];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  nixpkgs.config = {
    allowUnfree = true;
    # allowBroken = true;
  };
}
