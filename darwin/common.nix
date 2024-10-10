{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
  inherit (config) my;
in
{
  users.users.${my.user.name} = {
    inherit (my.user)
      description
      shell
      openssh
      packages
      ;
    home = "/Users/${my.user.name}";
  };

  fonts.packages = my.fonts.packages;

  environment.systemPackages = with pkgs; [
    pinentry_mac
  ];

  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
  };

  homebrew.enable = mkDefault true;

  programs.bash = mkDefault {
    enable = true;
    enableCompletion = true;
  };

  programs.zsh = mkDefault {
    enable = true;
    enableCompletion = true;
    enableFzfCompletion = true;
    enableFzfHistory = true;
    enableSyntaxHighlighting = true;
  };

  services.nix-daemon.enable = true;

  security.pam.enableSudoTouchIdAuth = mkDefault true;

  security.pki.certificateFiles = [ ];
  security.pki.certificates = [ ]; # TODO homelab certs
  security.pki.installCACerts = true;

  system.keyboard = mkDefault {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults = mkDefault {
    ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0; # disable moouse acceleration
    NSGlobalDomain."com.apple.springing.delay" = 0.0;
    NSGlobalDomain."com.apple.swipescrolldirection" = false; # disable "Natural" scrolling
    NSGlobalDomain.AppleKeyboardUIMode = 3;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.KeyRepeat = 1;
    NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
    NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
    NSGlobalDomain.NSUseAnimatedFocusRing = false; # disbale focus ring animnation
    NSGlobalDomain.NSWindowResizeTime = 0.0; # disable resize animation
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
    NSGlobalDomain._HIHideMenuBar = false; # auto-hide menu bar
    WindowManager.AutoHide = true;
    WindowManager.EnableStandardClickToShowDesktop = false; # false is "Only in Stage Manager"
    WindowManager.GloballyEnabled = false;
    WindowManager.HideDesktop = true;
    WindowManager.StandardHideWidgets = true;
    dock.appswitcher-all-displays = true;
    dock.autohide = true;
    dock.mru-spaces = false;
    dock.orientation = "bottom";
    dock.showhidden = true;
    finder.AppleShowAllExtensions = true;
    finder.AppleShowAllFiles = true;
    finder.FXDefaultSearchScope = "SCcf"; # default to current folder instead of "This Mac"
    finder.FXEnableExtensionChangeWarning = false;
    finder.QuitMenuItem = true;
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
    screencapture.disable-shadow = true;
    screencapture.show-thumbnail = true;
    trackpad.Clicking = false;
    trackpad.TrackpadThreeFingerDrag = true;
    # universalaccess.reduceMotion = true; # unsupported as of macOS 15.0.1 (24A348)
  };

  nix.configureBuildUsers = false; # https://github.com/LnL7/nix-darwin/issues/970
  nix.gc.automatic = true;
  nix.settings = my.nix.settings // {
    keep-derivations = false;
    auto-optimise-store = false; # https://github.com/NixOS/nix/issues/7273
  };
}
