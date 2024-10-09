{ config, lib, ... }:
{
  users.users.${config.my.user.name} = {
    shell = config.my.user.shell;
    home = "/Users/${config.my.user.name}";
  };

  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
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

  nix.configureBuildUsers = lib.mkDefault false; # https://github.com/LnL7/nix-darwin/issues/970

  nix.gc.automatic = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "repl-flake"
    ];
    keep-derivations = false;
    auto-optimise-store = false; # https://github.com/NixOS/nix/issues/7273
  };

}
