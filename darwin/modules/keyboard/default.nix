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
        type = with types;
          attrsOf (listOf (submodule {
            options = {
              title = mkOption {
                type = types.str;
                description = "Menu item text (e.g., Delete Conversation...)";
              };
              shortcut = mkOption {
                type = types.str;
                description = "Keyboard shortcut (e.g., @~9)";
              };
            };
          }));
        default = {};
        description = "App-specific keyboard shortcuts, keyed by bundle identifier";
      };
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts.extraUserActivation.text = let
      # Get app identifiers from attribute names
      apps = attrNames cfg.appShortcuts;

      # Generate commands to add apps to the custom menu array
      appCommands =
        map (app: ''
          defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add ${shellEscapeArg app}
        '')
        apps;

      # Generate commands to add keyboard shortcuts for each app
      shortcutCommands =
        concatMap (
          app:
            map (shortcut: ''
              defaults write ${shellEscapeArg app} NSUserKeyEquivalents -dict-add ${shellEscapeArg shortcut.title} -string ${shellEscapeArg shortcut.shortcut}
            '')
            cfg.appShortcuts.${app}
        )
        apps;

      allCommands = appCommands ++ shortcutCommands;
    in
      concatStringsSep "\n" allCommands;
  };
}
