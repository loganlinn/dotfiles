{ config, lib, ... }:
let cfg = config.programs.xcode; in
{
  options.programs.xcode = {
    enable = lib.mkEnableOption "Xcode";
  };

  config = lib.mkIf cfg.enable {
    homebrew.enable = true;
    homebrew.masApps.Xcode = 497799835;
  };
}
