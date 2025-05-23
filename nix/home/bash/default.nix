{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    bashInteractive # otherwise we get bashNonInteractive (?)
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };
}
