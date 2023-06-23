{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    yubikey-manager
    yubikey-personalization
    yubikey-personalization-gui
    yubico-pam
    yubioath-flutter # replaced yubioath-desktop
  ];

  # List of authorized YubiKey token IDs.
  # Refer to https://developers.yubico.com/yubico-pam for details on how to obtain the token ID of a YubiKey.
  pam.yubico.authorizedYubiKeys.ids = [
    "ccccccukcufv"
  ];
}
