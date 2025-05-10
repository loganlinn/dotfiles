{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.aider;
in
{
  options.my.aider = {
    enable = mkEnableOption "Aider";
    envFilePath = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
    playwright.enable = mkEnableOption "Playwright";
    voiceCoding.enable = mkEnableOption "Voice Coding";
  };
  config = mkIf cfg.enable {
    home.packages =
      [
        (if cfg.playwright.enable then pkgs.aider-chat-with-playwright else pkgs.aider-chat)
      ]
      ++ (optionals cfg.voiceCoding.enable (
        [ pkgs.portaudio ] ++ optional pkgs.stdenv.targetPlatform.isLinux pkgs.alsa-lib
      ));

    home.sessionVariables =
      {
        AIDER_ANALYTICS = "false";
      }
      // optionalAttrs (cfg.envFilePath != null) {
        AIDER_ENV_FILE = cfg.envFilePath;
      };
  };
}
