{
  config,
  pkgs,
  lib,
  ...
}: let
  unstable = import <nixpkgs-unstable> {};
in {
  imports = [
    <home-manager/nix-darwin>
    ./skhd.nix
  ];

  users.users.logan = {
    name = "logan";
    description = "Logan Linn";
    shell = pkgs.zsh;
    home = "/Users/logan";
  };

  home-manager.users.logan = {pkgs, ...}: {
    imports = [
      ./../../../nix/home/common.nix
      ./../../../nix/home/darwin.nix
      ./../../../nix/home/fonts.nix
      ./../../../nix/home/gh.nix
      # ./../../../nix/home/dev.nix
      ./../../../nix/home/zsh.nix
    ];

    home.stateVersion = "22.11";

    home.packages = with pkgs; [
      unstable.nodePackages_latest.graphite-cli
      alejandra
      babashka
      cargo
      clj-kondo
      clojure
      clojure-lsp
      cue
      cuelsp
      delta
      direnv
      java-language-server
      jdk
      k9s
      kubectl
      m-cli
      qemu
      rcm
      ripgrep
      rlwrap
      rnix-lsp
      shellcheck
      tmux
      # visualvm # error: collision between `/nix/store/fl966iylvy7c443j6p2b12ifx8bn0rdy-visualvm-2.1.4/LICENSE.txt' and `/nix/store/w98d37wz9kn4p6qmhhq7spvxc66phmnk-victor-mono-1.5.4/LICENSE.txt'
      zsh
    ];
    # programs.kitty.enable = true;

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zoxide.enable = true;

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # upgrade = true; # TRYME
    };
    taps = [
      # "d12frosted/emacs-plus"
      # "railwaycat/emacsport"
    ];
    brews = [
      # "azure-cli"
      # "libvterm"
      # {
      #  name = "emacs-plus@28";
      #  args = [
      #    "with-no-titlebar"
      #    "with-xwidgets"
      #    "with-native-comp"
      #    "with-modern-doom3-icon"
      #  ];
      # }
    ];
    casks = [
      "kitty"
      "slack"
    ];
  };

  environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  environment.systemPackages = with pkgs; [
    curl
    delta
    dejavu_fonts
    du-dust
    fd
    fzf
    htop
    lsd
    moreutils
    nixfmt
    rcm
    ripgrep
    tree
    vim
    wget
  ];

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      fira-code
      fira-code-symbols
      hack-font
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      ubuntu_font_family

      recursive
      (nerdfonts.override {
        fonts = [
          "DroidSansMono"
          "FiraCode"
          "JetBrainsMono"
        ];
      })
    ];
  };

  programs.man.enable = true;
  programs.bash.enableCompletion = true;

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enableBashCompletion = true;
  programs.zsh.enableFzfCompletion = true;
  programs.zsh.enableFzfGit = true;
  programs.zsh.enableFzfHistory = true;
  programs.zsh.enableSyntaxHighlighting = true;
  # programs.zsh.variables.cfg = "$HOME/.config/nixpkgs/darwin/configuration.nix";
  # programs.zsh.variables.darwin = "$HOME/.nix-defexpr/darwin";
  # programs.zsh.variables.nixpkgs = "$HOME/.nix-defexpr/nixpkgs";

  # services.yabai.enable = true;
  # services.yabai.package = pkgs.yabai;

  programs.nix-index.enable = true;

  services.nix-daemon.enable = true;

  nix.gc.automatic = true;

  # nix.package = pkgs.nix;
  nix.extraOptions =
    ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    ''
    + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  nix.configureBuildUsers = true;

  security.pam.enableSudoTouchIdAuth = true;

  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 25;
  system.defaults.NSGlobalDomain.KeyRepeat = 1;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
  system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
  system.defaults.NSGlobalDomain._HIHideMenuBar = false;

  system.defaults.dock.autohide = false;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;

  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.QuitMenuItem = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;

  system.defaults.trackpad.Clicking = false;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
