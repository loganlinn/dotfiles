{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.atuin = {
    enable = true;
    settings = {
      auto_sync = false;
      update_check = false;
      style = "compact";
      keys.prefix = "s";
    };
    flags = [
      "--disable-up-arrow"
    ];
    enableZshIntegration = true;
  };
}
