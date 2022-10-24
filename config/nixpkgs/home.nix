{pkgs, ...}: let
  pkgsCore = with pkgs; [
    binutils
    cmake
    coreutils-full # installs gnu versions
    curl
    du-dust
    fd
    gawk
    gcc
    git
    gnugrep
    gnumake
    gnused
    gnutar
    gnutls
    gzip
    moreutils # (chronic, combine, errno, ifdata, ifne, isutf8, lckdo, mispipe, parallel, pee, sponge, ts, vidir, vipe, zrun )
    rcm # dotfile management (rcup, mkrc, ...)
    ripgrep
    rlwrap
    sd # search and replace
    silver-searcher # ag
    tree
    wget
  ];

  pkgsFonts = with pkgs; [
    fira-code
    fira-code-symbols
    (nerdfonts.override {
      fonts = [
        "DroidSansMono"
        "FiraCode"
        "JetBrainsMono"
      ];
    })
  ];

  pkgsDev = with pkgs; [
    # general
    xh
    hey
    meld
    protobuf
    buf
    git-branchless
    bazel
    pre-commit

    # crystal
    crystal
    icr # crystal repl
    shards # package-manager

    # shell
    shfmt
    shellcheck
    shellharden

    # java
    # maven

    # golang

    # nix
    alejandra # formatter
    nixfmt
    nixpkgs-fmt # nix formatter

    # ruby
    ruby

    # rust
    rustc
    cargo
    rustfmt
    rust-analyzer

    # javascript
    yarn

    # kubernetes
    k9s
    krew # required after install: krew install krew
    kubectl
    kubectx
    kubernetes-helm
    kustomize
    stern
    kind

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
    graphviz
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
      url =
        "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
    }))
  ];

  imports = [
    ./programs
    ./services
  ];

  home = {
    username = "logan";
    homeDirectory = "/home/logan";
    stateVersion = "22.05";
  };

  home.packages = with pkgs;
    pkgsCore
    ++ pkgsFonts
    ++ pkgsTools
    ++ pkgsDev
    ++ [
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

      pinentry-emacs
      sqlite
      restic

      zk
    ];

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.krew/bin"
  ];

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

  xdg = {
    userDirs.enable = true;
    # desktopEntries = { };
  };
}
