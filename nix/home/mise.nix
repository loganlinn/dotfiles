{
  config,
  lib,
  ...
}:
{
  programs.mise = {
    enable = lib.mkDefault true;
    # enableZshIntegration = true;
    # enableBashIntegration = true;
    # enableFishIntegration = config.programs.fish.enable;
  };
  # programs.direnv.mise = {
  #   enable = lib.mkDefault config.programs.mise.enable;
  # };
}
