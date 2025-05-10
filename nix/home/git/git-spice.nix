{
  self',
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.git.spice;
in
{
  options.programs.git.spice = {
    enable = mkEnableOption "git-spice" // {
      default = true;
    };
    package = mkOption {
      type = types.package;
      default = self'.packages.git-spice;
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.shellAliases = {
      gsl = "${cfg.package}/bin/gs log long";
    };
    programs.git = {
      aliases.spice = "!${cfg.package}/bin/gs";
      extraConfig = {
        spice.submit.publish = mkDefault false;
        spice.log.all = mkDefault false;
      };
    };
    programs.zsh = {
      initExtra = ''
        function gs() {
          if (( $# )); then
            # Remember that time you created PR as your coworker?
            env GITHUB_TOKEN="$GIT_SPICE_GITHUB_TOKEN" gs "$@"
          else
            git status
          fi
        }
        complete -C ${cfg.package}/bin/gs gs
      '';
    };
  };
}
