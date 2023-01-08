{ home-manager, pkgs, lib, ... }: {
  imports = [
    home-manager.darwinModules.home-manager
  ];

  users.users.logan = {
    description = "Logan Linn";
    shell = pkgs.zsh;
    home = "/Users/logan";
  };

  home-manager.users.logan = import ./home.nix;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  homebrew = {
    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    # onActivation = {
    #   autoUpdate = false;
    #   # upgrade = true; # TRYME
    # };
    taps = [ "railwaycat/emacsport" "Azure/kubelogin" ];
    brews = [ "kubelogin" "emacs-mac" "azure-cli" "libvirt" "libvterm" "qemu" ];
    casks = [
      # "1password"
      # "iTerm"
      # "google-chrome"
      "kitty"
      "slack"
      "syncthing"
      "qmk-toolbox"
    ];
    masApps = { Tailscale = 1475387142; };
  };

  environment.darwinConfig = "$HOME/.dotfiles/nix/hosts/patchbook/darwin.nix";

  environment.systemPackages = with pkgs; [
    curl
    du-dust
    fd
    fzf
    htop
    lsd
    moreutils
    nixfmt
    ripgrep
    tree
    vim_configurable
    wget
  ];

  environment.variables = {
    # EDITOR = "vim";
    LANG = "en_US.UTF-8";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;
  };

  security.pam = {
    enableSudoTouchIdAuth = true;
  };

  services.nix-daemon.enable = true;

  nix = {
    configureBuildUsers = true;
    gc = {
      automatic = true;
      interval = {
        Hour = 3;
        Minute = 15;
      };
    };
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  system.defaults = {
    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 25;
      KeyRepeat = 1;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      _HIHideMenuBar = false;
    };

    dock = {
      autohide = true;
      mru-spaces = false;
      orientation = "bottom";
      showhidden = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
    };

    trackpad = {
      Clicking = false;
      TrackpadThreeFingerDrag = true;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
