{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.eza = {
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    colors = "auto";
    git = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--time-style=relative"
      "--hyperlink"
      "--color-scale=all"
      "--color-scale-mode=gradient"
    ];
  };
}
