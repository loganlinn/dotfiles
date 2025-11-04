{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.keyboard;
in {
  options = {
    modules.keyboard = {
      enable = mkEnableOption "keyboard shortcut system preferences module.";
      appShortcuts = mkOption {
        type = with types; attrsOf (attrsOf str);
        default = {};
        description = "App-specific keyboard shortcuts, keyed by bundle identifier";
      };
    };
  };

  config = mkIf cfg.enable {
    system.defaults.CustomUserPreferences =
      {
        "com.apple.universalaccess" = {
          "com.apple.custommenu.apps" = attrNames cfg.appShortcuts;
        };
      }
      // (mapAttrs (bundleId: shortcuts: {
          NSUserKeyEquivalents = shortcuts;
        })
        cfg.appShortcuts);
  };
}
