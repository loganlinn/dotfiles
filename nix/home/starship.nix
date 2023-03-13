{ config, lib, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = false;
    enableFishIntegration = true;
    settings = {
      gcloud = {
        disabled = true;
      };
      git_commit = {
        disabled = false;
        only_detached = false;
      };
      kubernetes = {
        disabled = true;
      };
    };
  };
}
