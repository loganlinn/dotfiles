{ lib, ... }:

{
  homebrew.masApps.Tailscale = 1475387142;

  services.tailscale = {
    magicDNS.enable = lib.mkDefault true;
  };
}
