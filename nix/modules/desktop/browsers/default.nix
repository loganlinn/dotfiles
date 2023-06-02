{
  options,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.modules.desktop.browsers;
in {
  imports = [
    ../../../home/firefox.nix # common settings
  ];

  options.modules.desktop.browsers = {
    default = mkOption {
      type = with types; nullOr str;
      default = null;
    };

    alternate = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };

  config = mkIf (cfg.default != null) {
    home.sessionVariables =
      optionalAttrs (cfg.default != null) {
        BROWSER = cfg.default;
      }
      // optionalAttrs (cfg.alternate != null) {
        BROWSER_ALT = cfg.alternate;
      };
  };
}
