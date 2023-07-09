{ config, lib, pkgs, ... }:

let
  withSystemd = lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.systemd;
in
{
  imports = [
    ../modules/nix-registry.nix
    ./accounts.nix
    ./clipboard.nix
    ./common-linux.nix
    ./fzf.nix
    ./git.nix
    ./neovim
    ./nix-path.nix
    ./ranger.nix
    ./readline.nix
    ./secrets.nix
    ./security.nix
    ./shell
  ];

  home.packages = with pkgs; [
    bandwhich # display current network utilization by process
    bc
    binutils
    cmake
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
    gzip
    moreutils
    neofetch
    pinentry
    procs # ps alternative
    rlwrap
    sd # sed alternative
    sops
    tree
    unzip
    xh # curl alternative
    zip
  ];

  home.sessionVariables = {
    DOCKER_SCAN_SUGGEST = "false";
    DOTNET_CLI_TELEMETRY_OPTOUT =  "true";
    DO_NOT_TRACK = "1";
    TELEMETRY_DISABLED = "1";
    DISABLE_TELEMETRY = "1";
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

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--type-add"
      "clj:include:clojure,edn"
      "--smart-case"
    ];
  };

  programs.htop = {
    # enable = true;
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
