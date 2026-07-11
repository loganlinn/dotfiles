{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.bun;
in
{
  programs.bun = {
    settings = {
      telemetry = false;
      install.saveTextLockfile = false; # generates a binary bun.lockb instead of a text-based bun.lock file when no lockfile is present.
      install.globalBinDir = "${config.my.user.home}/.bun/bin";
      install.lockfile.print = "yarn"; # generate yarn.lock alongside bun.lock
    };
  };
  home.sessionPath = lib.mkIf cfg.enable [cfg.settings.install.globalBinDir];
}
