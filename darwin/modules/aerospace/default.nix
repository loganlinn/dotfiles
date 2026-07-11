{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.aerospace;
in {
  options.programs.aerospace = {
    enable = mkEnableOption "aerospace window manager";
    configFile = mkOption {
      type = types.nullOr types.path;
      default = "${config.my.flakeDirectory}/config/aerospace/aerospace.toml";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.my.user.name} = {config, ...}: {
      xdg.configFile = optionalAttrs (cfg.configFile != null) {
        "aerospace/aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink cfg.configFile;
      };
    };

    # AeroSpace via Homebrew cask, NOT pkgs.aerospace / services.aerospace. Deliberate:
    #   - Stable /Applications/AeroSpace.app path preserves macOS Accessibility (TCC) grants +
    #     SMAppService login-item across upgrades. nix-store bundle path churns per version bump
    #     -> forces re-granting Accessibility + re-registering start-at-login.
    #   - brew upgrade decoupled from flake.lock / nixpkgs-maintainer-PR lag (AeroSpace is beta,
    #     frequent releases). Both sources ship the same prebuilt release zip; only delivery differs.
    #   - services.aerospace asserts start-at-login=false + runs AeroSpace from its own launchd
    #     agent. We instead leave startup to AeroSpace.app itself (SMAppService login item, toggled
    #     by start-at-login in config/aerospace/aerospace.toml) — a different model.
    # The cask sets up NO launchd agent / login item itself; it only installs the .app + CLI.
    homebrew = {
      # trusted = true so activation runs `brew trust --tap` before `brew bundle`
      # (nix-darwin's homebrew.taps.*.trusted defaults to false, and recent
      # Homebrew refuses casks from untrusted non-official taps).
      taps = [
        {
          name = "nikitabobko/tap";
          trusted = true;
        }
      ];
      casks = ["nikitabobko/tap/aerospace"];
    };

    environment.systemPath = [
      ./bin
    ];

    system.defaults = {
      # Move windows by holding ctrl+cmd and dragging any part of the window
      NSGlobalDomain.NSWindowShouldDragOnGesture = true;
      # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
      dock.expose-group-apps = true; # `true` means OFF
      # See: https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
      spaces.spans-displays = true; # `true` means spaces span all displays; `false` means spaces are separate for each display
    };
  };
}
