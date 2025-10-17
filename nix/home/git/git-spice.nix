{
  self,
  self',
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.git.git-spice;
in {
  options.programs.git.git-spice = {
    enable = mkEnableOption "git-spice";
    package = mkOption {
      type = types.package;
      default = self'.packages.git-spice;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    home.shellAliases = {
      grs = "command gs repo sync --restack";
    };
    programs.git = {
      aliases.spice = "!${cfg.package}/bin/gs";
      extraConfig = {
        spice.branchPrompt.sort = "comitteddate";
        spice.experiment.commitFixup = "true";
        spice.log.all = "false";
        spice.log.crFormat = "url";
        spice.log.pushStatusFormat = "aheadBehind";
        spice.logShort.crFormat = "id";
        spice.rebaseContinue.edit = "false";
        spice.repoSync.closedChanges = "ask";
        spice.shorthand.amend = "commit amend --no-edit";
        spice.shorthand.bottom = "trunk";
        spice.shorthand.main = "trunk";
        spice.shorthand.can = "commit amend --no-edit";
        spice.shorthand.checkout = "branch checkout";
        spice.shorthand.data = "!git log --patch refs/spice/data";
        spice.shorthand.delete = "branch delete";
        spice.shorthand.fold = "branch fold";
        spice.shorthand.lls = "log long --cr-status";
        spice.shorthand.lss = "log short --cr-status";
        spice.shorthand.modify = "commit amend";
        spice.shorthand.move = "upstack onto";
        spice.shorthand.pr = "!gh pr";
        spice.shorthand.pro = "!gh pr view --web";
        spice.shorthand.publish = "stack submit --publish";
        spice.shorthand.pull = "repo sync --restack";
        spice.shorthand.rename = "branch rename";
        spice.shorthand.reorder = "downstack edit";
        spice.shorthand.rsr = "repo sync --restack";
        spice.shorthand.squash = "branch squash";
        spice.shorthand.sync = "repo sync --restack";
        spice.shorthand.track = "branch track";
        spice.shorthand.untrack = "branch untrack";
        spice.submit.draft = "false";
        spice.submit.navigationComment = "multiple";
        spice.submit.navigationCommentSync = "downstack";
        spice.submit.publish = "true";
        spice.submit.web = "created";
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
