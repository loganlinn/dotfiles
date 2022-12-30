{ pkgs, ... }: {

  imports = [
    ./readline.nix
    ./shellAliases.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    age
    bash
    binutils
    cmake
    coreutils-full # installs gnu versions
    curl
    du-dust
    fd
    gawk
    git
    gnugrep
    gnumake
    gnused
    gnutar
    gnutls
    gzip
    moreutils
    neofetch
    procs
    rcm
    (ripgrep.override { withPCRE2 = true; })
    rlwrap
    sd
    silver-searcher
    sops
    tree
  ];

  home.sessionPath = [
    "$HOME/.dotfiles/bin"
    "$HOME/.dotfiles/local/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.krew/bin"
    "$HOME/go/bin"
  ];

  programs = {
    home-manager.enable = true;

    command-not-found.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    go.enable = true;

    gpg.enable = true;

    helix.enable = true;

    htop.enable = true;

    jq.enable = true;

    lsd = {
      enable = true;
      enableAliases = true;
    };

    password-store.enable = true;

    readline.enable = true;

    tealdeer.enable = true; # tldr command

    # yt-dlp.enable = false;
  };
}
