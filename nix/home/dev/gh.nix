{ lib, pkgs, ... }: {
  programs.gh = {
    enable = true;
    enableGitCredentialHelper = true;
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
}
