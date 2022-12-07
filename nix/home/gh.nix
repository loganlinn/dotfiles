{pkgs, ...}: {
  programs.gh = {
    enable = true;
    settings = {
      aliases = {
        o = "browse";
        op = "pr view --web";
        pro = "pr view --web";
        oi = "issue list --web";
        or = "release view --web";
        prs = "pr list --web";
        pco = "!gh prz | ifne xargs -n1 gh pr checkout";

        aliases = "alias list";

        check-fail = ''
          !gh pr checks "$@" | awk '$2=="fail"{ print $4 }'
        '';

        prz = ''
          !gh prl "$@" | fzf --ansi --color  | awk '{print $1}'
        '';

        prl = ''
          pr list

          --json number,title,headRefName
          --template '{{range .}}{{tablerow (printf "#%v" .number | autocolor "green") (.title | autocolor "white+h") (.headRefName | autocolor "blue")}}{{end}}'
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
    # extensions = [
    #   "dlvhdr/gh-dash"
    #   "gennaro-tedesco/gh-f"
    #   "korosuke613/gh-user-stars"
    # ];
  };
}
