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
    programs.git = {
      aliases.spice = "!${cfg.package}/bin/gs";
      extraConfig = {
        spice.submit.publish = mkDefault false;
        spice.submit.web = mkDefault true;
        spice.log.all = mkDefault true;
      };
    };
    programs.zsh.initExtraBeforeCompInit = ''
      eval "$(${cfg.package}/bin/gs shell completion zsh)"
    '';
  };
}
