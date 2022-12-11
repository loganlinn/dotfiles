{ pkgs, ... }: {
  imports = [ ./readline.nix ];

  home.packages = with pkgs; [
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
    moreutils
    neofetch
    rcm
    ripgrep
    rlwrap
    sd
    silver-searcher
    sops
    sysz
    tree
  ];

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.krew/bin"
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

    fzf.enable = true;

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

    yt-dlp.enable = false;

    zellij.enable = true;
  };

  xdg.userDirs.enable = true;
}
