{ config, lib, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = false;
    settings = {
      gcloud = {
        disabled = true;
      };
    };
  };
}
