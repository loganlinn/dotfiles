{ config, lib, ... }:
let
  inherit (lib) mkDefault;
  inherit (config) my;
in
{
  users.users.${my.user.name} = {
    inherit (my.user) description shell openssh;
    home = "/Users/${my.user.name}";
  };

  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
  };

  homebrew.enable = mkDefault true;

  programs.bash.enable = true;
  programs.bash.enableCompletion = true;

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.enableFzfCompletion = true;
  programs.zsh.enableFzfHistory = true;
  programs.zsh.enableSyntaxHighlighting = true;

  services.nix-daemon.enable = true;

  fonts.packages = my.fonts.packages;

  security.pam.enableSudoTouchIdAuth = mkDefault true;

  security.pki.certificateFiles = [ ];
  security.pki.certificates = [ ]; # TODO homelab certs
  security.pki.installCACerts = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults = {
    ".GlobalPreferences" = {
      "com.apple.mouse.scaling" = -1.0; # disable moouse acceleration
    };

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
      _HIHideMenuBar = false; # auto-hide menu bar
      "com.apple.swipescrolldirection" = false; # disable "Natural" scrolling
      NSUseAnimatedFocusRing = false; # disbale focus ring animnation
      NSWindowResizeTime = 0.0; # disable resize animation
      NSWindowShouldDragOnGesture = true;
      "com.apple.springing.delay" = 0.0;
    };

    dock = {
      autohide = true;
      mru-spaces = false;
      orientation = "bottom";
      showhidden = true;
      appswitcher-all-displays = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXDefaultSearchScope = "SCcf"; # default to current folder instead of "This Mac"
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad = {
      Clicking = false;
      TrackpadThreeFingerDrag = true;
    };

    WindowManager = {
      AutoHide = true;
      # Click wallpaper to reveal desktop Clicking your wallpaper will move all windows out
      # of the way to allow access to your desktop items and widgets.
      # Default is true. false means “Only in Stage Manager” true means “Always”
      EnableStandardClickToShowDesktop = false;
      GloballyEnabled = false;
      HideDesktop = true;
      StandardHideWidgets = true;
    };

    screencapture = {
      disable-shadow = true;
      show-thumbnail = true;
    };
  };

  nix.configureBuildUsers = false; # https://github.com/LnL7/nix-darwin/issues/970
  nix.gc.automatic = true;
  nix.settings = my.nix.settings // {
    keep-derivations = false;
    auto-optimise-store = false; # https://github.com/NixOS/nix/issues/7273
  };
}
