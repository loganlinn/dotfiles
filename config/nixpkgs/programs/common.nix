{pkgs, ...}: {
  imports = [
    ./readline.nix
  ];

  programs = {
    home-manager.enable = true;

    command-not-found.enable = true;

    bat.enable = true;

    bottom.enable = true;

    broot.enable = false;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };

    emacs = {
      enable = true;
      package = pkgs.emacsUnstable;
      extraPackages = (
        epkgs: (with epkgs; [
          vterm
        ])
      );
    };

    fzf.enable = true;

    gh = {
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

    go.enable = true;

    gpg = {
      enable = true;
    };

    helix.enable = true;

    htop.enable = true;

    java = {
      enable = true;
      package = pkgs.jdk11;
    };

    just.enable = true;

    jq.enable = true;

    lsd = {
      enable = true;
      enableAliases = true;
    };

    nnn = {
      enable = false;
    };

    kitty = {
      enable = false; # TODO: finish migrating from config file
      font = "Fira Code Retina";
      # keybindings = {};
      # settings = {};
      # environment = {};
      extraConfig = ''
        # Nord Theme
          background #1c1c1c
          foreground #ddeedd
          cursor #e2bbef
          selection_background #4d4d4d
          color0 #3d352a
          color8 #554444
          color1 #cd5c5c
          color9 #cc5533
          color2 #86af80
          color10 #88aa22
          color3 #e8ae5b
          color11 #ffa75d
          color4 #6495ed
          color12 #87ceeb
          color5 #deb887
          color13 #996600
          color6 #b0c4de
          color14 #b0c4de
          color7 #bbaa99
          color15 #ddccbb
          selection_foreground #1c1c1c
      '';
    };

    pandoc.enable = true;

    password-store.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    readline.enable = true;

    rofi = {
      enable = true;
      pass = {
        enable = true;
      };
    };

    tealdeer.enable = true; # tldr command

    yt-dlp.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    zsh = {
      enable = false;
      dotDir = ".zsh";
    };
  };
}
