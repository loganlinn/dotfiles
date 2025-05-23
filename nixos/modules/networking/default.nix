{lib, ...}:
with lib; {
  imports = [./wireless.nix];

  networking.networkmanager.enable = mkDefault true;

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = mkDefault false;
}
