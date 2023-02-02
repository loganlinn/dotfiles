{ config
, lib
, pkgs
, ...
}:
let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;
in
{
  imports = [
    ./accounts.nix
    ./git.nix
    ./neovim
    ./security.nix
    ./readline.nix
    ./rofi
    ./secrets.nix
    ./shellAliases.nix
  ];

  home.packages = with pkgs;
    [
      binutils
      cmake
      coreutils-full # installs gnu versions
      curl
      du-dust
      dtrx # Do The Right Extraction
      fd
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
      procs
      rcm
      ripgrep
      rlwrap
      sd
      silver-searcher
      sops
      tree
      xh
      zenith
      (writeShellApplication {
        name = "switch";
        text =
          if isDarwin
          then ''
            darwin-rebuild switch --impure --flake ~/.dotfiles#"$(whoami)@$(hostname -s)" "$@"
          ''
          else ''
            home-manager switch -b backup --flake ~/.dotfiles#"$(whoami)@$(hostname -s)" "$@"
          '';
      })
    ]
    ++ lib.optionals isLinux [
      sysz
    ];

  home.sessionVariables = {
    EDITOR = "vim";
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

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.btop.enable = true;

  programs.command-not-found.enable = !config.programs.nix-index.enable;

  programs.nix-index.enable = lib.mkDefault false;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
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
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = lib.mkDefault 86400;
    maxCacheTtl = lib.mkDefault 86400;
    pinentryFlavor = lib.mkDefault "gtk2";
    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';
  };
}
