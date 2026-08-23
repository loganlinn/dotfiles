{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.my; let
  pr-search = {
    inbox = ''-author:@me -reviewed-by:@me review-involves:@me is:open'';
    outbox = ''author:@me review:required is:open -is:draft'';
    approved = ''author:@me review:approved is:open -is:draft'';
    rejected = ''author:@me review:changes-requested is:open -is:draft'';
    merged = ''author:@me is:merged'';
    closed = ''author:@me is:closed'';
    drafts = ''author:@me is:draft '';
    created = ''author:@me'';
    reviewed = ''reviewed-by:@me'';
    testing = ''is:merged label:needs-testing label:needs-qa'';
  };
  pr-fields = [
    "additions"
    "assignees"
    "author"
    "autoMergeRequest"
    "baseRefName"
    "baseRefOid"
    "body"
    "changedFiles"
    "closed"
    "closedAt"
    "closingIssuesReferences"
    "comments"
    "commits"
    "createdAt"
    "deletions"
    "files"
    "fullDatabaseId"
    "headRefName"
    "headRefOid"
    "headRepository"
    "headRepositoryOwner"
    "id"
    "isCrossRepository"
    "isDraft"
    "labels"
    "latestReviews"
    "maintainerCanModify"
    "mergeCommit"
    "mergeStateStatus"
    "mergeable"
    "mergedAt"
    "mergedBy"
    "milestone"
    "number"
    "potentialMergeCommit"
    "projectCards"
    "projectItems"
    "reactionGroups"
    "reviewDecision"
    "reviewRequests"
    "reviews"
    "state"
    "statusCheckRollup"
    "title"
    "updatedAt"
    "url"
  ];
in {
  home.shellAliases = {
    gist = "gh gist";
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      aliases =
        listToAttrs (map (field: nameValuePair "pr-${field}" ''pr view --json ${field} --jq .${field}'') pr-fields)
        // mapAttrs' (name: search: nameValuePair "pr-${name}" ''pr list --search "${search}"'') pr-search
        // {
          aliases = "alias list";
          release-checkout = ''!tag=$(gh release view "$@" --json tagName --jq '.tagName') && git fetch origin tag "$tag" && git checkout --detach "$tag"'';
          o = ''!gh browse --branch="$(git rev-parse --abbrev-ref HEAD)" .'';
          co = "!gh prz | ifne xargs -n1 gh pr checkout";
          coa = "!gh-pr-checkout-authored-by \"$@\"";
          repo-fork-sync = ''!gh api /repos/{owner}/{repo}/merge-upstream --method POST --field "branch=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)"'';
          markdown = ''!gh api /markdown -f text="$(cat "''${1-/dev/stdin}")"'';
          gfm = ''markdown'';
          octocat = "api /octocat";
          license = ''!gh api --paginate --jq 'if type == "object" then .body else .[].name end' licenses/"''${1-}"'';
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
          my-team = "!gh my-org | sed '/${config.my.github.username}/d'";
          my-prs = "pr list --author @me";
          my-runs = ''!gh run list --user "$(gh api user --jq .login)"''; # does not support @me
          my-user = "api user";
          whoami = "api user";
          checks = "pr checks";
          diff = ''!gh pr diff "''$@" | diffnav'';
          pr-by= ''!author=$1 && [[ -n $author ]] || author=$(gh my-org | fzf) && pr list --search "author:''$author"'';
          prw = "pr list --web";
          prv = "pr view --web";
          prl = ''!CLICOLOR_FORCE=1 gh pr list --json number,title,headRefName,createdAt --template '{{tablerow "ID" "TITLE" "BRANCH" "CREATED AT"}}{{range .}}{{tablerow (printf "#%v" .number | autocolor "green") .title (.headRefName | autocolor "cyan") (timeago .createdAt)}}{{end}}{{tablerender}}' "$@"'';
          prz = ''!gh prl "$@" | fzf --ansi --header-lines=1 --accept-nth=1'';
          pro = ''!gh pr view --web "$@"'';
          lgtm = "pr review --approve";
          edit-reviewers = ''!gh my-team | ${pkgs.gum}/bin/gum choose --selected="$(gh reviewers)"'';
          stars = ''api user/starred --template '{{range .}}{{tablerow .full_name .description .html_url }}{{end}}' '';
          land = "pr merge --squash --delete-branch";
          userlist = ''!${config.xdg.configHome}/gh/userlists.sh "$@"'';
        };
    };
  };

  xdg.configFile = {
    "gh-dash/config.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/gh-dash/config.yml";
    "gh-enhance/config.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/gh-enhance/config.yml";
    "gh/userlists.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/gh/userlists.sh";
  };

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
    config.floating.criteria = [{class = "gh-dash";}];
  };

  home.packages = [
  ];

  # programs.raycast.scriptCommands.github-open-review-requested = {
  #   title = "GitHub Open Review Requested";
  #   mode = "silent";
  #   icon = "🤖";
  #   author = config.my.github.username;
  #   authorURL = "https://github.com/${config.my.github.username}";
  #   description = "Fuzzy-pick a PR awaiting your review and open it in the browser.";
  #   runtimeInputs = [
  #     gh-review-requested
  #     config.programs.gh.package
  #   ];
  #   script = ''
  #     exec ${getExe gh-review-requested} "$@"
  #   '';
  # };
}
