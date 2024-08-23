{ config, lib, ... }:
with lib;
{
  config = mkMerge [
    (mkIf config.services.xserver.enable {
      console.useXkbConfig = true;
      services.xserver = {
        autorun = mkDefault true;
        autoRepeatDelay = 440; # default: 660ms
        autoRepeatInterval = 30; # default: 25Hz
        #  xkb directory (and the xorg.conf file) gets exported to /etc/X11/xkb, which is useful if you have to often look stuff up in it.
        exportConfiguration = mkDefault true;
        xkb.layout = "us";
        xkb.options = concatStringsSep "," [
          "ctrl:nocaps"
        ];
        # Whether to enable the DontZap option, which binds Ctrl+Alt+Backspace
        # to forcefully kill X. This can lead to data loss and is disabled by default.
        enableCtrlAltBackspace = mkDefault false;
      };
    })
    (mkIf config.services.libinput.enable {
      services.libinput.touchpad = {
        accelProfile = "adaptive";
        buttonMapping = "1 3 2";
        disableWhileTyping = true;
        horizontalScrolling = false;
        naturalScrolling = true;
        scrollMethod = "twofinger";
        tapping = false;
        tappingDragLock = true;
      };
    })
  ];
}
