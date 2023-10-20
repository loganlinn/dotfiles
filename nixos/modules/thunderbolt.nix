{ pkgs, ... }:
{
  services.hardware.bolt.enable = true;
  environment.systemPackages = with pkgs; [
    thunderbolt # tbtacl
  ];
}
