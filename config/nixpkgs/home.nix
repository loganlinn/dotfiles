{ pkgs, ... }:

let
in {
  home.username = "logan";
  home.homeDirectory = "/home/logan";
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.emacs.package = pkgs.emacsUnstable;

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  # TIP: use following vim command to sorts packages based on first alpha character 
  #
  #      /home\.packages =/+1,/end:home\.packages/-1 sort /\a/ r
  #
  # PROTIP: yank the command and execute it with `:@"`
  home.packages = with pkgs; [
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
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
    ((emacsPackagesFor emacsPgtkNativeComp).emacsWithPackages (epkgs: [ epkgs.vterm ]))
    fd
    fzf
    gifsicle
    gnutls
    hyperfine
    # imagemagick
    jq
    lsd
    mdsh
    pinentry_emacs
    neofetch
    nixfmt
    ponymix
    procs
    restic
    (ripgrep.override { withPCRE2 = true; })
    rlwrap
    ruby
    sd
    shellharden
    sqlite
    trash-cli
    # zoom-us
    zoxide
    zstd
  ]; # end:home.packages

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # See also: https://github.com/NixOS/nixpkgs/tree/master/pkgs/tools/misc

  #  programs = {
  #    gpg = {
  #      enable = false;
  #      homedir = "${config.xdg.dataHome}/gnupg";
  #    };
  #
  #    # https://github.com/nix-community/home-manager/blob/master/modules/programs/git.nix 
  #    git = {
  #      enable = false;
  #      userName = "Logan Linn";
  #      userEmail = "logan@llinn.dev";
  #      signing = {
  #        key = "32A48B412F1CA30ADB1B54382C3CDAE023DB6616";
  #        signByDefault = true;
  #      };
  #      ignores = [ "*~" "*.swp" "node_modules" ".venv" ".cpcache" ];
  #      includes = [ { path = "~/.config/git/alias"; } { path = "~/.config/git/config.local"; } ];
  #      aliases = {
  #        wt   = "worktree";
  #        lswt = "worktree list";
  #        mkwt = "!f() { git worktree add \"$(git rev-parse --show-toplevel)+$@\"; }; f";
  #        rmwt = "!f() { git worktree remove \"$(git rev-parse --show-toplevel)+$@\"; }; f";
  #        wtls = "lswt";
  #        wtmk = "mkwt";
  #        wtrm = "rmwt";
  #        aliases = "config --get-regexp alias";
  #      };
  #      extraConfig = {
  #        commit.verbose = true;
  #        init.defaultBranch = "main";
  #        pull.rebase = true;
  #      };
  #      delta.enable = true;
  #    };
  #
  #  };

  programs.password-store.enable = true;

  programs.command-not-found.enable = true;

  #  services = {
  #    gpg-agent = {
  #      enable = true;
  #      enableSshSupport = true;
  #      defaultCacheTtl = 3600;
  #      defaultCacheTtlSsh = 3600;
  #    };
  #
  #    syncthing.enable = true;
  #  };
}
