{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my;
{
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      aliases = {
        o = ''!gh browse --branch="$(git rev-parse --abbrev-ref HEAD)" .'';
        diff = "pr diff";
        prw = "pr list --web";
        pco = "!gh prz | ifne xargs -n1 gh pr checkout";
        prl = ''!CLICOLOR_FORCE=1 gh pr list --json number,title,headRefName,createdAt --template '{{tablerow "ID" "TITLE" "BRANCH" "CREATED AT"}}{{range .}}{{tablerow (printf "#%v" .number | autocolor "green") .title (.headRefName | autocolor "cyan") (timeago .createdAt)}}{{end}}{{tablerender}}' "$@"'';
        prz = ''!gh prl "$@" | fzf --ansi --header-lines=1 --accept-nth=1'';
        pro = ''!gh pr view --web "$@"'';
        prO = "!gh prz | ifne xargs -n1 gh pr view --web"; # open another PR

        checks = "pr checks";
        # failed = ''pr checks --json bucket,completedAt,description,event,link,name,startedAt,state,workflow --jq 'select(.state != "SUCCESS" and .state != "SKIPPED"' '';
        # procc = ''!gh failed | | .link)[]' | xargs -L1 open'';

        repo-fork-sync = ''!gh api /repos/{owner}/{repo}/merge-upstream --method POST --field "branch=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)"'';

        markdown = ''!gh api /markdown -f text="$(cat "''${1-/dev/stdin}")"'';

        my-org = ''
          !gh api graphql -F owner='{owner}' -F name='{repo}' -f query='
            query($name: String!, $owner: String!) {
              repository(owner: $owner, name: $name) {
                owner {
                  ... on Organization {
                    login
                    teams(first: 100) {
                      nodes {
                        slug
                      }
                    }
                    membersWithRole(first: 100) {
                      nodes {
                        login
                      }
                    }
                  }
                }
              }
            }
          ' | jq -r '
            .data.repository.owner
            | .login as $org
            | (.teams.nodes|map("\($org)/\(.slug)")) as $teams
            | (.membersWithRole.nodes|map(.login)) as $users
            | ($teams | sort) + ($users | sort_by(ascii_downcase))
            | .[]'
        '';

        my-team = "!gh my-org | sed '/loganlinn/d'";
        my-prs = "pr list --author @me";
        my-runs = "run list --user loganlinn";

        reviewers = "pr view --json 'reviewRequests' --jq '.reviewRequests[]'";
        edit-reviewers = ''!gh my-team | ${pkgs.gum}/bin/gum choose --selected="$(gh reviewers)"'';

        aliases = "alias list";

        gists = ''
          !GIST=$(gh gist list --limit 128 | fzf -0 | cut -f1) || exit $? ; [[ -n $GIST ]] && gh gist view "$GIST" "$@"
        '';

        stars = ''
          api user/starred --template '{{range .}}{{tablerow .full_name .description .html_url }}{{end}}'
        '';
      };
    };
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
    categories = [
      "Development"
      "Utility"
      "Network"
      "ConsoleOnly"
    ];
    settings = {
      StartupWMClass = "gh-dash";
    };
  };

  xsession.windowManager.i3 = mkIf config.xsession.windowManager.i3.enable {
    config.floating.criteria = [ { class = "gh-dash"; } ];
  };
}
