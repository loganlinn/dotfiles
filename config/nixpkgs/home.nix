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
    gawk
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
    protobuf
    buf


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
    cargo
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
  imports = [
    ./programs
    ./services
  ];

  home = {
    username = "logan";
    homeDirectory = "/home/logan";
    stateVersion = "22.05";
  };

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

    pinentry-emacs
    sqlite
    restic
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
