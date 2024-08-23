{ pkgs, lib, ... }:
{
  # services.yubikey-agent.enable = true;

  services.pcscd.enable = lib.mkDefault true; # for yubikey smartcard

  environment.systemPackages = with pkgs; [ yubikey-personalization ];
}
