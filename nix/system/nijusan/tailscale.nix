{ config, pkgs, ... }:

{
  # Tailscale
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/tailscale.nix

  environment.systemPackages = with pkgs; [
    tailscale
  ];

  services.tailscale.enable = true;

  # Strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups.
  networking.firewall.checkReversePath = "loose";
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
}

