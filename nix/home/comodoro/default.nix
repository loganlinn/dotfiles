{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.comodoro;
in
{
  options = {
    programs.comodoro.enableBashIntegration = mkEnableOption "Bash integration";
    programs.comodoro.enableZshIntegration = mkEnableOption "Zsh integration";
    programs.comodoro.enableFishIntegration = mkEnableOption "Fish integration";
  };

  config = {
    programs.comodoro = {
      enable = mkDefault true;
      enableBashIntegration = mkDefault cfg.enable;
      enableZshIntegration = mkDefault cfg.enable;
      enableFishIntegration = mkDefault cfg.enable;
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
