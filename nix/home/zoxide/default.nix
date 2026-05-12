{
  lib,
  ...
}:
{
  programs.zoxide = {
    enable = lib.mkDefault true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  home.sessionVariables._ZO_FZF_OPTS = "--select-1";
}
