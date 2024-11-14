{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.sunbeam;
in
{
  options = {
    programs.sunbeam = {
      enable = mkEnableOption "sunbeam";
      enableBashIntegration = mkEnableOption "sunbeam bash completions" // {
        default = true;
      };
      enableZshIntegration = mkEnableOption "sunbeam zsh completions" // {
        default = true;
      };
      enableFishIntegration = mkEnableOption "sunbeam fish completions" // {
        default = true;
      };
    };
  };
  config = mkIf cfg.enable {
    homebrew.taps = [ "pomdtr/tap" ];
    homebrew.brews = [ "pomdtr/tap/sunbeam" ];

    home-manager.users.${config.my.user.name} = {
      programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
        if [[ $TERM != "dumb" ]]; then
          eval "$(${config.homebrew.brewPrefix}/sunbeam completion bash)"
        fi
      '';
      programs.zsh.initExtra = mkIf cfg.enableZshIntegration ''
        if [[ $TERM != "dumb" ]]; then
          eval "$(${config.homebrew.brewPrefix}/sunbeam completion zsh)"
        fi
      '';
      programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
        if test "$TERM" != "dumb"
          eval "$(${config.homebrew.brewPrefix}/sunbeam completion fish)"
        end
      '';
    };

  };
}
