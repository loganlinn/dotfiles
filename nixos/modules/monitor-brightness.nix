{ config, lib, pkgs, ... }:

let
  user = config.my.user.name;
in
{
  # ddcutils requires i2c
  hardware.i2c.enable = true;

  environment.systemPackages = with pkgs; [
    ddcutil
    brightnessctl
  ];

  security.sudo.extraRules = [{
    users = [ user ];
    commands = [
      {
        command = "${pkgs.ddcutil}/bin/ddcutil";
        options = [ "NOPASSWD" ];
      }
    ];
  }];

  users.users.${user} = {
    extraGroups = [ "i2c" ];
  };
}
