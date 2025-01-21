{
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
    package = mkPackageOption pkgs "git-spice" { };
    options = {
      # TODO https://abhinav.github.io/git-spice/cli/config
      # branchCheckout.showUntracked
      # branchCreate.commit
      # forge.github.apiUrl
      # forge.github.url
      # forge.gitlab.url
      # forge.gitlab.oauth.clientID
      # log.all
      # rebaseContinue.edit
      # submit.listTemplatesTimeout
      # submit.navigationComment
      # submit.publish
      # submit.web
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
        spice.submit.web = mkDefault true;
        spice.log.all = mkDefault true;
        spice.shorthand.sync = "repo sync";
        spice.shorthand.continue = "rebase continue";
        spice.shorthand.abort = "rebase abort";
        spice.shorthand.rename = "branch rename";
        spice.shorthand.checkout = "branch checkout";
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
