{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = mkIf config.services.xserver.enable {
    console.useXkbConfig = true;
    services.xserver = {
      autorun = mkDefault true;
      xkb.layout = "us";
      xkb.options = "ctrl:nocaps,terminate:ctrl_alt_bksp";
      #  xkb directory (and the xorg.conf file) gets exported to /etc/X11/xkb, which is useful if you have to often look stuff up in it.
      exportConfiguration = mkDefault true;
      libinput.touchpad = mkDefault {
        accelProfile = "adaptive";
        buttonMapping = "1 3 2";
        disableWhileTyping = true;
        horizontalScrolling = false;
        naturalScrolling = true;
        scrollMethod = "twofinger";
        tapping = false;
        tappingDragLock = true;
      };
    };
  };
}
