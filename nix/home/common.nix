{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./pam.nix
    ./secrets.nix
    ./readline.nix
    ./shellAliases.nix
  ];

  home.packages = with pkgs; [
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
    pinentry
    procs
    rcm
    (ripgrep.override {withPCRE2 = true;})
    rlwrap
    sd
    silver-searcher
    sops
    tree
  ];

  home.sessionVariables = {
    DOCKER_SCAN_SUGGEST = "false";
    DO_NOT_TRACK = "1";
    HOMEBREW_NO_ANALYTICS = "1";
    NEXT_TELEMETRY_DISABLED = "1";
  };

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

    # helix.enable = true;

    htop = {
      enable = true;
      settings = {
        hide_kernel_threads = 1;
        show_program_path = 1;
        show_cpu_usage = 1;
        show_cpu_frequency = 0;
        show_cpu_temperature = 1;
        degree_fahrenheit = 0;
        enable_mouse = 1;
        tree_view = 0;
      };
    };

    jq.enable = true;

    lsd = {
      enable = true;
      enableAliases = true;
    };

    tealdeer.enable = true; # tldr command

    # yt-dlp.enable = false;
  };
}
