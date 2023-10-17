{ config, lib, pkgs, ... }:

{

  users.users.logan = {
    name = "logan";
    description = "Logan Linn";
    shell = pkgs.zsh;
    home = "/Users/logan";
  };

  programs.bash.enable = true;
  programs.zsh.enable = true;

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
    settings.experimental-features = ["nix-command" "flakes"];
  };

}
