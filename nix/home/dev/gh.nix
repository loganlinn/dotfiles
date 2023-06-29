{ lib, pkgs, ... }: {
  programs.gh = {
    enable = true;
    enableGitCredentialHelper = true;
    settings = {
      aliases =
        let
          gh = lib.getExe pkgs.gh;
          gum = lib.getExe pkgs.gum;
        in
        {
          o = "browse";
          op = "pr view --web";
          pro = "pr view --web";
          oi = "issue list --web";
          or = "release view --web";
          prs = "pr list --web";
          pco = "!${gh} prz | ifne xargs -n1 ${gh} pr checkout";

          markdown = ''!${gh} api /markdown -f text="$(cat "''${1-/dev/stdin}")"'';

          org-members = "api /orgs/{owner}/members --jq '.[].login'";
          teammates = "!${gh} org-memebers | sed '/loganlinn/d'";
          reviewers = "pr view --json 'reviewRequests' --jq '.reviewRequests[]'";
          edit-reviewers = ''
            !${gh} teammates |
             ${gum} choose --selected="$(${gh} reviewers)"
          '';

          aliases = "alias list";

          checks = "checks";
          check-fail = ''
            !${gh} pr checks "$@" | awk '$2=="fail"{ print $4 }'
          '';

          prl = ''
            pr list
            --json number,title,headRefName
            --template '{{range .}}{{tablerow (printf "#%v" .number | autocolor "green") (.title | autocolor "white+h") (.headRefName | autocolor "blue")}}{{end}}'
          '';

          prz = ''
            !${gh} prl "$@" | fzf --ansi --color  | awk '{print $1}'
          '';

          land = ''
            !${gh} prz --author=@me | ifne xargs -n1 ${gh} pr merge --rebase --delete-branch
          '';

          landf = ''
            !${gh} prz --author=@me | ifne xargs -n1 ${gh} pr merge --rebase --delete-branch --admin
          '';

          gists = ''
            !GIST=$(${gh} gist list --limit 128 | fzf -0 | cut -f1) || exit $? ; [[ -n $GIST ]] && ${gh} gist view "$GIST" "$@"
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
