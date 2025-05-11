{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.aider;
  yaml = pkgs.formats.yaml { };
in
{
  options.my.aider = {
    enable = mkEnableOption "Aider";
    playwright.enable = mkEnableOption "Playwright";
    voiceCoding.enable = mkEnableOption "Voice Coding";
    settings = mkOption {
      type = yaml.type;
      default = {
        gitignore = false;
        auto-accept-architect = false;
        auto-commits = false;
        subtree-only = true;
        attribute-co-authored-by = false;
        commit = false;
        analytics-disable = true;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      [
        (if cfg.playwright.enable then pkgs.aider-chat-with-playwright else pkgs.aider-chat)
      ]
      ++ (optionals cfg.voiceCoding.enable (
        [ pkgs.portaudio ] ++ optional pkgs.stdenv.targetPlatform.isLinux pkgs.alsa-lib
      ));

    home.file = optionalAttrs (cfg.settings != { }) {
      ".aider.conf.yml".source = yaml.generate ".aider.conf.yml" cfg.settings;
    };

    programs.git.ignores = [ ".aider*" ];
  };
}
