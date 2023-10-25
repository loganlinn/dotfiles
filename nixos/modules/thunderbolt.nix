{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    thunderbolt # tbtacl
  ];
  services.hardware.bolt.enable = true;
  # services.udev.extraRules = ''
  #   ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
  # '';
}
