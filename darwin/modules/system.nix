{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
{
  system = {

    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    activationScripts.postActivation.text = ''
      if ! test -f /etc/nix-darwin/flake.nix; then
        echo >&2 "Missing '/etc/nix-darwin/flake.nix'. Consider \`ln -s /path/to/flake.nix /etc/nix-darwin/flake.nix\`."
      fi
    '';

    keyboard = mkDefault {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = mkDefault {
      ".GlobalPreferences" = {
        # NOTE: setting to -1 reportedly disables moouse acceleration, but
        #       this actually configures Mouse tracking speed.
        #       Setting to -1 is like setting to slowest, which is and incredibly slow.
        #       Valid range is 1-3, with 1 being the slowest and 3 being the fastest.
        "com.apple.mouse.scaling" = 1.0;
      };

      NSGlobalDomain = {
        "com.apple.sound.beep.feedback" = 1;
        "com.apple.springing.delay" = 0.0;
        "com.apple.swipescrolldirection" = false; # disable "Natural" scrolling
        AppleKeyboardUIMode = 3; # full keyboard control.
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 25; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        KeyRepeat = 3; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSUseAnimatedFocusRing = false; # disbale focus ring animnation
        NSWindowResizeTime = 0.0; # disable resize animation
        NSWindowShouldDragOnGesture = true;
        _HIHideMenuBar = false; # auto-hide menu bar
      };

      WindowManager = {
        AutoHide = true;
        EnableStandardClickToShowDesktop = false; # false is "Only in Stage Manager"
        GloballyEnabled = false;
        HideDesktop = true;
        StandardHideWidgets = false;
      };

      dock = {
        appswitcher-all-displays = true;
        show-recents = false;
        autohide = true;
        mru-spaces = false;
        orientation = "bottom";
        showhidden = true;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXDefaultSearchScope = "SCcf"; # When performing a search, search the current folder by default
        FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
        FXPreferredViewStyle = "Nlsv"; # icnv=Icon, Nlsv=List, clmv=Column, Flwv=Gallery
        FXRemoveOldTrashItems = true;
        NewWindowTarget = "Home";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true; # show status bar
        _FXShowPosixPathInTitle = true; # show full path in finder title
      };

      loginwindow = {
        DisableConsoleAccess = false; # typing “>console” for a username at the login window.
        GuestEnabled = false;
      };

      screencapture = {
        disable-shadow = true;
        show-thumbnail = true;
        location = "~/Desktop";
        type = "png";
      };

      trackpad = {
        Clicking = false;
        TrackpadThreeFingerDrag = true;
      };

      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      #
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          # AppleSpacesSwitchOnActivate = true; # automatically switch to a new space when switching to the application
        };
        NSGlobalDomain = {
          WebKitDeveloperExtras = true; # Add a context menu item for showing the Web Inspector in web views
          PMPrintingExpandedStateForPrint = true;
          PMPrintingExpandedStateForPrint2 = true;
          _HIHideMenuBar = false;
          "com.apple.mouse.tapBehavior" = null; # disable tap to click
        };
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on external file systems
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.spaces" = {
          "spans-displays" = 0; # Display have seperate spaces
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0; # Click wallpaper to reveal desktop
          StandardHideDesktopIcons = 0; # Show items on desktop
          HideDesktop = 0; # Do not hide items on desktop & stage manager
          StageManagerHideWidgets = 0;
          StandardHideWidgets = 0;
        };
        "com.apple.screensaver" = {
          askForPassword = 1;
          askForPasswordDelay = 10; # seconds
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
      };
    };
  };
}
