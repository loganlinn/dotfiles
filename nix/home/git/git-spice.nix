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
        spice.shorthand.amend = "commit amend --no-edit";
        spice.shorthand.bottom = "trunk";
        spice.shorthand.can = "commit amend --no-edit";
        spice.shorthand.checkout = "branch checkout";
        spice.shorthand.delete = "branch delete";
        spice.shorthand.fold = "branch fold";
        spice.shorthand.modify = "commit amend";
        spice.shorthand.move = "upstack onto";
        spice.shorthand.rename = "branch rename";
        spice.shorthand.reorder = "downstack edit";
        spice.shorthand.squash = "branch squash";
        spice.shorthand.track = "branch track";
        spice.shorthand.untrack = "branch untrack";
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
