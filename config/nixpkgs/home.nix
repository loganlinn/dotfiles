{ pkgs,  ... }:

{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  home.username = "logan";
  home.homeDirectory = "/home/logan";
  # TIP: use following vim command to sorts packages based on first alpha character 
  #
  #      /home\.packages =/+1,/end:home\.packages/-1 sort /\a/ r
  #
  # PROTIP: yank the command and execute it with `:@"`
  home.packages = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    asciinema
    bat
    bottom
    broot
    binutils
    delta
    dive
    doctl
    du-dust
    entr
    fd
    fzf
    gifsicle
    gnutls
    hyperfine
    # imagemagick
    jq
    kubectl
    lsd
    mdsh
    neofetch
    nixfmt
    pinentry_emacs
    ponymix
    procs
    restic
    (ripgrep.override { withPCRE2 = true; })
    rlwrap
    ruby
    rofi
    sd
    silver-searcher
    shellharden
    sqlite
    trash-cli
    zoxide
    zstd
  ]; # end:home.packages

  home.stateVersion = "22.05";

  programs.home-manager.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.password-store.enable = true;

  programs.command-not-found.enable = true;

  # home.file = {
  #   ".emacs.d" = {
  #     source = doom-emacs
  #     recursive = true;
  #   };
  # };

  programs.emacs = {
    enable = true;
    package = pkgs.emacsNativeComp;
    extraPackages = (epkgs:
      (with epkgs; [
        vterm
      ])
    );
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
}
