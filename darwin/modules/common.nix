{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkDefault
    optionalString
    forEach
    listToAttrs
    ;
  inherit (config) my;
in
{
  imports = [
    # homebrew (TODO move to own separate file)
    {
      homebrew.enable = mkDefault true;
      programs.zsh.interactiveShellInit = optionalString config.homebrew.enable ''
        # Tell zsh how to find brew installed completions
        if [[ -v HOMEBREW_PREFIX ]]; then
          fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
        fi
      '';
      environment.variables.HOMEBREW_NO_ANALYTICS = "1";
    }
  ];

  config = {
    assertions = [
      {
        assertion = config.users.users.${my.user.name}.home == "/Users/${my.user.name}";
        message = "check config.my.user.home";
      }
    ];

    users.users.${my.user.name} = {
      inherit (my.user)
        description
        shell
        home
        openssh
        packages
        ;
    };

    fonts.packages = my.fonts.packages;

    environment.variables = my.environment.variables;

    environment.systemPackages = with pkgs; [
      bashInteractive
      pinentry_mac
      (writeShellScriptBin "bundle-id" ''
        ${pkgs.fd}/bin/fd \
          --search-path=/System/Applications \
          --search-path=/Applications \
          --search-path=$HOME/Applications \
          --follow \
          --type=directory \
          --extension=app \
          --max-depth=2 \
          "''${1?APP}" \
          --exec /usr/bin/mdls -name kMDItemCFBundleIdentifier -r
      '')
    ];

    programs.bash = {
      enable = true;
      completion.enable = true;
    };

    programs.zsh = {
      enable = true;
      enableCompletion = mkDefault true;
      enableFzfCompletion = mkDefault true;
      enableFzfHistory = mkDefault true;
      enableSyntaxHighlighting = mkDefault true;
    };

    services.nix-daemon.enable = true;

    security.pam.enableSudoTouchIdAuth = mkDefault true;

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
      WindowManager.StandardHideWidgets = false;
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

    system.activationScripts.postActivation.text = ''
      if ! test -f /etc/nix-darwin/flake.nix; then
        echo >&2 "Missing '/etc/nix-darwin/flake.nix'. Consider \`ln -s /path/to/flake.nix /etc/nix-darwin/flake.nix\`."
      fi
    '';

    environment.etc = listToAttrs (
      forEach
        [
          "nixpkgs"
          "nix-darwin"
        ]
        (input: {
          name = "nix/inputs/${input}";
          value = {
            source = "${inputs.${input}}";
          };
        })
    );

    nix.configureBuildUsers = false; # https://github.com/LnL7/nix-darwin/issues/970
    nix.gc.automatic = true;
    nix.settings = my.nix.settings // {
      keep-derivations = false;
      auto-optimise-store = false; # https://github.com/NixOS/nix/issues/7273
    };
    nix.registry = my.nix.registry;
  };
}
