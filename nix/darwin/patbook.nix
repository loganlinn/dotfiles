{pkgs, lib, ...}: {

  imports = [
    ./skhd.nix
    ./yabai.nix
  ];

  users.users.logan = {
    name = "logan";
    description = "Logan Linn";
    shell = pkgs.zsh;
    home = "/Users/logan";
  };

  homebrew = {
    enable = true;
    brewPrefix = "/opt/homebrew/bin";
    # onActivation = {
    #   autoUpdate = false;
    #   # upgrade = true; # TRYME
    # };
    taps = [
      # "d12frosted/emacs-plus"
      # "railwaycat/emacsport"
      "Azure/kubelogin"
    ];
    brews = [
      "kubelogin"
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
      # "google-chrome"
      "kitty"
      "slack"
    ];
  };

  environment = {
    darwinConfig = "$HOME/.dotfiles/nix/darwin/$HOST.nix";

    systemPackages = with pkgs; [
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
    # profiles = [];
    # extraInit = "";
    # etc = {};
    variables = {
      # EDITOR = "vim";
      LANG = "en_US.UTF-8";
    };
  };

  programs.man.enable = true;

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

  programs.nix-index.enable = true;

  services.nix-daemon.enable = true;

  nix = {
    configureBuildUsers = true;
    gc.automatic = true;
    extraOptions =
      ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
      ''
      + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';
  };

  security = {
    pam.enableSudoTouchIdAuth = true;
    pki.certificates = [];
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
      orientation = "left";
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
