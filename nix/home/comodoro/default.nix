{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.comodoro;
in {
  options = {
    programs.comodoro.enableBashIntegration = mkEnableOption "Bash integration";
    programs.comodoro.enableZshIntegration = mkEnableOption "Zsh integration";
    programs.comodoro.enableFishIntegration = mkEnableOption "Fish integration";
  };

  config = {
    programs.comodoro = {
      package = mkDefault (pkgs.callPackage ./comodoro.nix {});
      enable = mkDefault true;
      enableBashIntegration = mkDefault cfg.enable;
      enableZshIntegration = mkDefault cfg.enable;
      enableFishIntegration = mkDefault cfg.enable;
      settings = {
        presets.example = {
          # TCP configuration, used by server binders and by clients.
          # Requires the cargo feature "tcp".
          tcp.host = "localhost";
          tcp.port = 1234;

          # A cycle is a step in the timer lifetime, represented by a name and a
          # duration. You can either define custom cycles:
          cycles = [
            {
              name = "Work";
              duration = 5;
            }
            {
              name = "Rest";
              duration = 3;
            }
          ];

          # Predefined cycles can also be used:
          # preset = "pomodoro" | "52/17"

          # Force the timer to stop after the given amount of loops:
          # cycles-count = 5

          # Customize the timer precision. Available options: second, minute, hour.
          # timer-precision = "minute"

          # A hook can be either a shell command or a system notification. Hook
          # names follow the format "on-{name}-{event}", where "name" is the
          # kebab-case version of the cycle name, and "event" the type of event:
          # begin, running, set, pause, resume, end.
          hooks.on-work-begin.notify.summary = "Comodoro";
          hooks.on-work-begin.notify.body = "Work started!";
          # hooks.on-work-begin.cmd = "notify-send Comodoro 'Work started!'"
        };
      };
    };

    services.comodoro.enable = mkDefault true;

    programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
      if [[ $TERM != "dumb" ]]; then
        eval "$(${cfg.package}/bin/comodoro completion bash)"
      fi
    '';

    programs.zsh.completionInit = mkIf cfg.enableZshIntegration ''
      if [[ $TERM != "dumb" ]]; then
        eval "$(${cfg.package}/bin/comodoro completion zsh)"
      fi
    '';

    programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
      if test "$TERM" != "dumb"
        eval "$(${cfg.package}/bin/comodoro completion fish)"
      end
    '';
  };
}
