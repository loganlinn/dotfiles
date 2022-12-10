{pkgs, ...}: {
  imports = [
    ./readline.nix
    ./git.nix
    ./gh.nix
  ];

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
      nix-direnv = {
        enable = true;
      };
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

    zellij = {
      enable = true;
    };
  };

  #editorconfig = {
  #  enable = true;
  #  settings = {
  #    "*" = {
  #      charset = "utf-8";
  #      end_of_line = "lf";
  #      trim_trailing_whitespace = true;
  #      insert_final_newline = true;
  #      max_line_width = 99;
  #      indent_style = "space";
  #      indent_size = 2;
  #    };
  #  };
  #};

  xdg.userDirs.enable = true;
}
