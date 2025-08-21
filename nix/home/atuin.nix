{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.atuin = {
    enable = false;
    daemon.enable = lib.mkDefault config.programs.atuin.enable;
    settings = {
      auto_sync = false;
      sync_address = "https://atuin.llinn.dev";
      dialect = "us";
      enter_accept = false;
      inline_height = 20;
      invert = true;
      keys.prefix = "s";
      prefers_reduced_motion = true;
      style = "compact";
      update_check = false;
    };
    flags = [
      "--disable-up-arrow"
    ];
    enableZshIntegration = true;
  };
}
