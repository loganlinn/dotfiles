{ config, lib, pkgs, ... }:

{

  config = lib.mkIf pkgs.stdenv.isLinux {

    home.keyboard = {
      layout = "us";
      options = [ "ctrl:nocaps" "compose:ralt" ];
    };

  };
}
