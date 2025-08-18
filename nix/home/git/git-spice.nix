{
  self,
  self',
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.git.git-spice;
in
{
  options.programs.git.git-spice = {
    enable = mkEnableOption "git-spice";
    package = mkOption {
      type = types.package;
      default = self'.packages.git-spice;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    programs.git = {
      aliases.spice = "!${cfg.package}/bin/gs";
      extraConfig = {
        spice.branchPrompt.sort = "comitteddate";
        spice.log.all = false;
        spice.log.crFormat = "url";
        spice.log.pushStatusFormat = "aheadBehind";
        spice.logShort.crFormat = "id";
        spice.rebaseContinue.edit = "false";
        spice.shorthand.amend = "commit amend --no-edit";
        spice.shorthand.bottom = "trunk";
        spice.shorthand.can = "commit amend --no-edit";
        spice.shorthand.checkout = "branch checkout";
        spice.shorthand.delete = "branch delete";
        spice.shorthand.fold = "branch fold";
        spice.shorthand.modify = "commit amend";
        spice.shorthand.move = "upstack onto";
        spice.shorthand.publish = "stack submit --publish";
        spice.shorthand.rename = "branch rename";
        spice.shorthand.reorder = "downstack edit";
        spice.shorthand.rsr = "repo sync --restack";
        spice.shorthand.squash = "branch squash";
        spice.shorthand.track = "branch track";
        spice.shorthand.untrack = "branch untrack";
        spice.submit.publish = false;
        spice.submit.web = "false";
        spice.submit.draft = "false";
      };
    };
    programs.zsh = {
      completionInit = ''
        complete -C ${cfg.package}/bin/gs gs
      '';
      initContent = mkBefore ''
        gs() {
          if (( $# )) && [[ ! -e $1 ]]; then
            # Remember that time you created PR as your coworker?
            env GITHUB_TOKEN="$GIT_SPICE_GITHUB_TOKEN" command gs "$@"
          else
            git status .
          fi
        }
      '';
    };
  };
}
