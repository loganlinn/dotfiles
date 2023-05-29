{ config, lib, pkgs, ... }:

let
  withSystemd = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.systemd;
in
{
  imports =
    [
      ./accounts.nix
      ./clipboard.nix
      ./common-linux.nix
      ./git.nix
      ./neovim
      ./security.nix
      ./readline.nix
      ./secrets.nix
      ./shellAliases.nix
    ];

  home.packages = with pkgs; [
    bc
    binutils
    cmake
    comma # github.com/nix-community/comma
    coreutils-full # installs gnu versions
    curl
    dig
    dogdns # dig on steroids
    du-dust # du alternative
    duf # df alternative
    fd # find alternative
    gawk
    gnugrep
    gnumake
    gnused
    gnutar
    gnutls
    gping # ping alternative
    gzip
    moreutils
    neofetch
    nvd # nix package version diffs (e.x. nvd diff /run/current-system result)
    pinentry
    procs # ps alternative
    rcm # TODO no longer used (!)
    ripgrep # grep alternative
    rlwrap
    sd # sed alternative
    silver-searcher # grep alternative
    sops
    tree
    unzip
    xh # curl alternative
    zip
  ];

  home.sessionVariables = {
    DOCKER_SCAN_SUGGEST = "false";
    DO_NOT_TRACK = "1";
    HOMEBREW_NO_ANALYTICS = "1";
    NEXT_TELEMETRY_DISABLED = "1";
  };

  home.sessionPath = [
    "${config.my.dotfilesDir}/bin"
    "${config.my.dotfilesDir}/local/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.krew/bin"
    "$HOME/go/bin"
  ];

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "onedark";
      theme_background = false;
    };
  };

  programs.command-not-found.enable = !config.programs.nix-index.enable;

  programs.nix-index.enable = lib.mkDefault false;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    config = {
      global = {
        warn_timeout = "10s";
      };
      whitelist = {
        prefix = [
          "${config.home.homeDirectory}/.dotfiles"
          "${config.home.homeDirectory}/src/github.com/loganlinn"
        ];
      };
    };
  };

  programs.go.enable = true;

  programs.gpg.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    tmux.enableShellIntegration = config.programs.tmux.enable;
  };

  programs.htop = {
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

  programs.jq.enable = true;

  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  programs.tealdeer.enable = true; # tldr command

  services.gpg-agent = {
    enable = withSystemd;
    enableSshSupport = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    defaultCacheTtl = lib.mkDefault 86400;
    maxCacheTtl = lib.mkDefault 86400;
    pinentryFlavor = "tty";
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
