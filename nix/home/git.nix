{ config
, lib
, pkgs
, ...
}:
with lib; let
  workEmail = "logan@patch.tech";
  workConfig = pkgs.writeText "work.gitconfig" ''
    [user]
    email = ${workEmail}
  '';
  workDirs = [ "~/src/github.com/patch-tech/" ];
  git = getExe pkgs.git;
in
{
  programs.git = {
    enable = true;
    aliases = {
      amend = "commit --amend --reuse-message HEAD";
      touch = ''!${git} commit --amend --date="$(date -r)"'';
      undo = "reset --soft HEAD~1";
      stack = "!gt stack";
      upstack = "!gt upstack";
      us = "!gt upstack";
      downstack = "!gt downstack";
      ds = "!gt downstack";
      b = "!gt branch";
      l = "!gt log";
      default-branch = ''
        !f() {
          ${git} rev-parse --git-dir &>/dev/null || return $?;
          for a in heads remotes; do
            for b in origin upstream; do
              for c in main trunk master; do
                if ${git} show-ref --quiet --verify "refs/$a/$b/$c"; then
                  printf %q "$c";
                  return;
                fi;
              done;
            done;
          done;
          gh api /repos/{owner}/{repo} --jq '.default_branch'
        }; f'';
    };
    includes =
      [
        { path = "~/.config/git/config.local"; }
        { path = ./git/include/gitalias.txt; }
      ]
      ++ forEach workDirs (workDir: {
        path = "${workConfig}";
        condition = "gitdir:${workDir}";
      });
    delta = {
      enable = true;
      options = {
        hunk-header-style = "omit";
        theme = "zenburn";
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
      branch.sort = "-committerdate";
      color.ui = true;
      commit.verbose = true; # include diff in commit message editor
      core.askPass = optionalString (with config.services.gpg-agent; enable && enableSshSupport) ""; # needs to be empty to use terminal for ask pass
      github.user = "loganlinn";
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.default = "tracking";
      rebase.autosquash = true;
      stash.showPatch = true;
      stash.showIncludeUntracked = true;
    };
    # hooks
    ignores = [ ".localinn" ];
    signing.key = null; # let GnuPG decide
    userEmail = "logan@llinn.dev";
    userName = "Logan Linn";
  };
}
