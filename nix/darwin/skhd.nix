{ config, lib, pkgs, ... }:

{
  services.skhd = {
    enable = true;
    skhdConfig = ''
      cmd + ctrl - return : open -n -a kitty.app
      cmd + ctrl + shift - return : open -n -a Google\ Chrome.app
      cmd + ctrl - e : open -n -a Emacs.app
    '';
  };
}
