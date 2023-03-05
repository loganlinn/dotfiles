{ config, lib, pkgs, ... }:

{

  users.users.logan = {
    name = "logan";
    description = "Logan Linn";
    shell = pkgs.zsh;
  };

  services.nix-daemon.enable = true;

  nix = {
    configureBuildUsers = true;
    gc = {
      automatic = true;
      interval = {
        Hour = 4;
        Minute = 15;
      };
    };
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

}
