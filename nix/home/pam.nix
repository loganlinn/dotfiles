{ config, lib, pkgs, ... }:

{
  pam.yubico.authorizedYubiKeys.ids = [
    "ccccccukcufv"
  ];
}
