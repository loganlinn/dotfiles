{
  options,
  config,
  pkgs,
  lib,
  ...
}:
{
  users.users.logan = {
    name = "logan";
    description = "Logan Linn";
    shell = pkgs.zsh;
    home = "/Users/logan";
  };

  homebrew.enable = lib.mkDefault true;

  programs.bash.enable = true;

  programs.zsh.enable = true;

  services.nix-daemon.enable = true;

  fonts.packages = config.my.fonts.packages;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
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

  nix.configureBuildUsers = true;
  nix.gc = {
    automatic = true;
    interval = {
      Hour = 4;
      Minute = 15;
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    keep-derivations = false;
    auto-optimise-store = false; # https://github.com/NixOS/nix/issues/7273
  };

}
