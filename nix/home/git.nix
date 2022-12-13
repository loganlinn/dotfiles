{
  lib,
  pkgs,
  ...
}: let
  workEmail = "logan@patch.tech";
  workConfig = pkgs.writeText "work.gitconfig" ''
    [user]
    email = ${workEmail}
  '';
  workDirs = ["~/src/github.com/patch-tech/"];
in {
  programs.git = {
    enable = true;
    aliases = {
      amend = "commit --amend --reuse-message HEAD";
      touch = ''!git commit --amend --date="$(date -r)"'';
      undo = "reset --soft HEAD~1";
      stack = "!gt stack";
      upstack = "!gt upstack";
      us = "!gt upstack";
      downstack = "!gt downstack";
      ds = "!gt downstack";
      b = "!gt branch";
      l = "!gt log";
    };
    includes =
      [
        {path = "~/.config/git/config.local";}
        {path = ./git/include/gitalias.txt;}
      ]
      ++ lib.forEach workDirs (workDir: {
        path = "${workConfig}";
        condition = "gitdir:${workDir}";
      });
    delta = {
      enable = true;
      options = {
        hunk-header-style = "omit";
        syntax-theme = "GitHub";
        navigate = "true";
        side-by-side = "true";
        line-numbers = "true";
      };
    };
    extraConfig = {
      advice.detachedHead = false;
      advice.skippedCherryPicks = false;
      advice.statusHints = false;
      branch.autoSetupRebase = "always";
      branch.sort = "-commiterdate";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      github.user = "loganlinn";
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.default = "tracking";
      rebase.autosquash = true;
    };
    # hooks
    ignores = [".localinn"];
    signing.key = null; # let GnuPG decide
    userEmail = "logan@llinn.dev";
    userName = "Logan Linn";
  };
}
