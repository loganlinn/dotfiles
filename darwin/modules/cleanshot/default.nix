{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.cleanshot;
  user = config.my.user.name;

  # Carbon modifier flags
  cmdKey = 256;
  shiftKey = 512;
  optionKey = 2048;
  controlKey = 4096;

  # Carbon virtual key codes
  key = {
    "Return" = 36;
    "Space" = 49;
    "3" = 20;
    "4" = 21;
    "5" = 23;
    "6" = 22;
  };

  mkShortcutJSON = modifiers: carbonKey:
    builtins.toJSON {
      carbonModifiers = foldl' (a: b: a + b) 0 modifiers;
      inherit carbonKey;
    };

  # macOS symbolic hotkey IDs for screenshots:
  #   28 = Cmd+Shift+3 (full screen to file)
  #   29 = Cmd+Shift+Ctrl+3 (full screen to clipboard)
  #   30 = Cmd+Shift+4 (selection to file)
  #   31 = Cmd+Shift+Ctrl+4 (selection to clipboard)
  #  184 = Cmd+Shift+5 (screenshot/recording options)
  screenshotHotkeyIds = [
    28
    29
    30
    31
    184
  ];

  mkDisabledHotkey = id: {
    name = toString id;
    value = {
      enabled = false;
    };
  };

  # CleanShot stores shortcuts as NSData (hex-encoded JSON).
  # nix-darwin's CustomUserPreferences writes strings, not data,
  # so we use an activation script with `defaults write -data`.
  writeShortcutData = name: json: ''
    launchctl asuser "$(id -u -- ${user})" sudo --user=${user} -- \
      defaults write pl.maketheweb.cleanshotx ${name} \
        -data "$(printf '%s' ${escapeShellArg json} | xxd -p | tr -d '\n')"
  '';

  shortcuts = {
    # Capture
    LAVAtakeFullscreen = mkShortcutJSON [ cmdKey shiftKey ] key."3";
    LAVAtakeArea = mkShortcutJSON [ cmdKey shiftKey ] key."4";
    LAVAtakeAllInOne = mkShortcutJSON [ cmdKey shiftKey ] key."5";
    LAVAtakeAreaCopy = mkShortcutJSON [ cmdKey shiftKey controlKey ] key."4";
    LAVAtakeOCR = mkShortcutJSON [ cmdKey shiftKey ] key."6";
    # Recording sub-mode keys (active within All-in-One overlay)
    LAVAselectWindowVideo = mkShortcutJSON [ ] key."Space";
    LAVAstartVideoRecording = mkShortcutJSON [ ] key."Return";
    LAVAstartStopScrollingCapture = mkShortcutJSON [ ] key."Return";
    LAVAstartGIFRecording = mkShortcutJSON [ optionKey ] key."Return";
  };
in
{
  options.programs.cleanshot = {
    enable = mkEnableOption "CleanShot X screenshot tool";
  };

  config = mkIf cfg.enable {
    system.defaults.CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = builtins.listToAttrs (map mkDisabledHotkey screenshotHotkeyIds);
      };
      "pl.maketheweb.cleanshotx" = {
        # Save location
        exportPath = config.my.userDirs.screenshots;
        # Capture behavior
        captureWithoutDesktopIcons = true;
        captureCursor = true;
        captureWindowShadow = true;
        freezeScreen = true;
        crosshairMode = 1;
        # Quick Access Overlay popup
        popupSize = 2;
        autoClosePopup = false;
        popupAutoCloseMode = 0;
        popupAskForDestinationWhenSaving = false;
        deletePopupAfterDragging = true;
        # After capture actions: [0=show popup, 1=copy to clipboard]
        afterScreenshotActions = [ 0 1 ];
        # After video actions: [0=show popup, 5=?]
        afterVideoActions = [ 0 5 ];
        # Recording
        rememberRecordingArea = true;
        showCountdown = true;
        showKeystrokes = true;
        # Cloud
        cloudCopyDirectLink = true;
        optimizeCloudScreenshots = false;
        # Display
        transparentWindowBackground = true;
        add2xRetinaSuffix = false;
        # Privacy
        analyticsAllowed = false;
      };
    };

    system.activationScripts.postActivation.text =
      concatStringsSep "\n" (mapAttrsToList writeShortcutData shortcuts);
  };
}
