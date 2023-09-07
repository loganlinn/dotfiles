{ config, lib, pkgs, ... }:

with lib;
with lib.my;

{
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      aliases = {
        o = "browse";
        oi = "issue list --web";
        or = "release view --web";
        pck = "pr checks";
        check-fail = ''!gh pr checks "$@" | awk '$2=="fail"{ print $4 }' '';
        pcl = "pr close";
        pco = "!gh prz | ifne xargs -n1 gh pr checkout";
        pcr = "pr create";
        pd = "pr diff";
        pl = "pr list";
        pm = "pr merge";
        prO = "!gh prz | ifne xargs -n1 gh pr view --web"; # open another PR
        pre = "pr reopen";
        pro = "pr view --web";
        prs = "pr list --web";
        pv = "pr view";
        pvw = "pr view --web";
        ps = "pr status";

        markdown = ''!gh api /markdown -f text="$(cat "''${1-/dev/stdin}")"'';

        my-org = "api /orgs/{owner}/members --jq '.[].login'";
        my-team = "!gh my-org | sed '/loganlinn/d'";

        reviewers = "pr view --json 'reviewRequests' --jq '.reviewRequests[]'";
        edit-reviewers = ''!gh my-team | ${pkgs.gum}/bin/gum choose --selected="$(gh reviewers)"'';

        aliases = "alias list";


        prl = ''
          pr list
          --json number,title,headRefName
          --template '{{range .}}{{tablerow (printf "#%v" .number | autocolor "green") (.title | autocolor "white+h") (.headRefName | autocolor "blue")}}{{end}}'
        '';

        prz = ''
          !gh prl "$@" | fzf --ansi --color  | awk '{print $1}'
        '';

        land = ''
          !gh prz --author=@me | ifne xargs -n1 gh pr merge --rebase --delete-branch
        '';

        landf = ''
          !gh prz --author=@me | ifne xargs -n1 gh pr merge --rebase --delete-branch --admin
        '';

        gists = ''
          !GIST=$(gh gist list --limit 128 | fzf -0 | cut -f1) || exit $? ; [[ -n $GIST ]] && gh gist view "$GIST" "$@"
        '';

        stars = ''
          api user/starred --template '{{range .}}{{tablerow .full_name .description .html_url }}{{end}}'
        '';
      };
    };

    extensions = with pkgs; [
      gh-dash
    ];
  };

  xdg.configFile."gh-dash/config.yml".source = ../../../config/gh-dash/config.yml;

  xdg.desktopEntries.gh-dash = mkIf pkgs.stdenv.isLinux {
    name = "gh-dash";
    genericName = "GitHub Dashboard";
    comment = "Terminal-based dashboard for GitHub Pull Requests and Issues";
    type = "Application";
    # StartupWMClass setting below was not working (unclear where it was getting dropped/ignored), so exec kitty directly
    exec = "${toExe config.programs.kitty} --class=gh-dash --title=gh-dash --detach ${toExe config.programs.gh} extension exec dash";
    # exec = "${config.programs.gh.package}/bin/gh extension exec dash";
    # terminal = true;
    terminal = true;
    icon = "github"; # i.e. xdg.dataFile."local/share/icons/hicolor/*/apps/github.*"
    categories = [ "Development" "Utility" "Network" "ConsoleOnly" ];
    settings = {
      StartupWMClass = "gh-dash";
    };
  };

  xsession.windowManager.i3 = mkIf config.xsession.windowManager.i3.enable {
    config.floating.criteria = [{ class = "gh-dash"; }];
  };
}
