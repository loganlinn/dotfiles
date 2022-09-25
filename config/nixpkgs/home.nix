{ pkgs,  ... }:

let
  pkgsCore = with pkgs; [
    coreutils
    binutils
    gnumake
    cmake
    curl
    du-dust
    gcc
    fd
    git
    gnutls
    (ripgrep.override { withPCRE2 = true; }) # (rg)
    moreutils # (chronic, combine, errno, ifdata, ifne, isutf8, lckdo, mispipe, parallel, pee, sponge, ts, vidir, vipe, zrun )
    rlwrap
    silver-searcher # ag
    sd   # search and replace
    rcm  # dotfile management (rcup, mkrc, ...)
    tree
    wget
  ];

  pkgsFonts = with pkgs; [
    fira-code
    fira-code-symbols
  ];

  pkgsDev = with pkgs; [
    # crystal
    crystal
    icr     # crystal repl
    shards  # package-manager

    # shell
    shfmt
    shellcheck
    shellharden
    
    # general
    hey
    meld

    # java
    # maven

    # golang
    gopls
    godef

    # nix 
    nixfmt
    rnix-lsp    # nix language server
    nixpkgs-fmt # nix formatter
    statix      # linter for nix

    # ruby
    ruby

    # rust
    rustc
    rustfmt
    rust-analyzer

    # javascript
    yarn

    # kubernetes
    k9s
    kubectl
    kustomize
    kubectx
    kubernetes-helm
    stern   # pod logs. https://github.com/wercker/stern

    # rust
    # pkgs.rustup # rust toolchain
    # pkgs.rustc # compiler
    # pkgs.cargo # package manager
    # pkgs.rustfmt # formatter
    # pkgs.clippy # the useful clippy
    # pkgs.rust-analyzer # lsp for rust
    # pkgs.cargo-edit # dep management
  ];

  pkgsTools = with pkgs; [
    asciinema
    delta
    dive
    doctl
    hyperfine
    jless
    mdsh
    neofetch
    pqrs
    procs
    scrot
    sysz
    tig
    trash-cli
    xclip
  ];

in {
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  home.stateVersion = "22.05";
  home.username = "logan";
  home.homeDirectory = "/home/logan";

  xdg = {
    userDirs.enable = true;
    # desktopEntries = { };
  };

  # dconf = {
  #   settings = { };
  # }

  # home.file = {
  #   ".emacs.d" = {
  #     source = ...
  #     recursive = true;
  #   };
  # };

  # home.file = with pkgs; {
  #   "lib/jvm/jdk11".source = jdk11;
  #   "lib/jvm/jdk17".source = jdk17;
  # };

  # pam.yubico.authorizedYubiKeys = {
  #   ids = [ ];
  # };

  # home.sessionVariables = { };

  home.packages = with pkgs; pkgsCore ++ pkgsFonts ++ pkgsTools ++ pkgsDev ++ [
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science

    chafa # show images in terminal using half blocks

    #ffmpeg
    #imagemagick
    gifsicle
    gifski

    #ponymix

    pinentry_emacs
    sqlite
    restic
  ];

  programs = {
    command-not-found.enable = true;

    bat.enable = true;

    bottom.enable = true;

    broot.enable = false;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    emacs = {
      enable = true;
      package = pkgs.emacsNativeComp;
      extraPackages = (epkgs:
      (with epkgs; [
        vterm
      ])
      );
    };

    fzf.enable = true;

    gh = {
      enable = true;
      settings = {
        aliases = {
          o    = "browse";
          op   = "pr view --web";
          oi   = "issue list --web";
          or   = "release view --web";
          prs  = "pr list --web";
          pco  = "!gh prz | ifne xargs -n1 gh pr checkout";

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

    helix.enable = true;

    home-manager.enable = true;

    htop.enable = true;

    java = {
      enable = true;
      package = pkgs.jdk11;
    };

    jq.enable = true;

    lsd = {
      enable = true;
      enableAliases = true;
    };

    nnn = {
      enable = true;
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

    zoxide = {
      enable = true;
    };

    zsh = {
      enable = false;
      dotDir = ".zsh";
    };
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacsUnstable;
    client = {
      enable = true;
    };
    startWithUserSession = true;
    defaultEditor = true;
  };

  services.home-manager = {
    autoUpgrade = {
      enable = true;
      frequency = "weekly";
    };

  };

  # services.git-sync = {
  #   enable = true;
  #   repositories = {
  #     name = {
  #       path = "";
  #       uri = "";
  #       interval = 86400;
  #     }
  #   };
  # };

  services.syncthing = {
    enable = true;
    tray = {
      enable = false;
    };
  };

  systemd.user = {
    timers = {

      # example = {
      #   Unit.Description = "Example timer";
      #   Install.WantedBy = [ "timers.target" ];
      #   Timer = {
      #     OnCalendar = cfg.frequency;
      #     Unit = "example.service";
      #     Persistent = true;
      #   };
      # };
      # services.example = {
      #   Unit.Description = "Example service";
      #   Service.ExecStart = toString
      #     (pkgs.writeShellScript "example" ''
      #       ${pkgs.nix}/bin/date
      #     '');
      # };
    };
  };
}
