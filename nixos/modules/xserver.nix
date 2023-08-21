{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {};

  config = lib.mkIf config.services.xserver.enable {
    services.xserver.autorun = true;
    services.xserver.layout = "us";
    services.xserver.xkbOptions = "ctrl:nocaps"; # Make Caps Lock a Control key

    services.xserver.displayManager = {
      lightdm.enable = true;
      lightdm.greeters.slick.enable = true;
      lightdm.greeters.slick.cursorTheme = {
        package = pkgs.numix-cursor-theme;
        name = "Numix-Cursor-Light";
        size = 24;
      };
      defaultSession = "none+xsession";
    };

    services.xserver.windowManager = {
      session = lib.singleton {
        name = "xsession";
        start = ''
          ${pkgs.runtimeShell} "$HOME/.xsession" &
          waitPID=$!
        '';
      };
    };

    # | Display Mode | Freq (Hz)    | PxClk (MHz) | Sync Polarity |
    # |--------------|--------------|-------------|---------------|
    # |  640 x 400   | 31.5 / 70.1  | 25.2        | -/+           |
    # |  640 x 480   | 31.5 / 59.9  | 25.2        | -/-           |
    # |  640 x 480   | 37.5 / 75.0  | 31.5        | -/-           |
    # |  720 x 400   | 31.5 / 70.1  | 28.3        | -/+           |
    # |  800 x 600   | 37.9 / 60.3  | 40.0        | +/+           |
    # |  800 x 600   | 46.9 / 75.0  | 49.5        | +/+           |
    # | 1024 x 768   | 48.4 / 60.0  | 65          | -/-           |
    # | 1024 x 768   | 60.0 / 75.0  | 78.8        | +/+           |
    # | 1152 x 864   | 67.5 / 75.0  | 108         | +/+           |
    # | 1280 x 800   | 49.3 / 59.9  | 71          | +/-           |
    # | 1280 x 1024  | 64.0 / 60.0  | 108         | +/+           |
    # | 1280 x 1024  | 80.0 / 75.0  | 135         | +/+           |
    # | 1600 x 1200  | 75.0 / 60.0  | 162         | +/+           |
    # | 1920 x 1080  | 67.5 / 60.0  | 148.5       | +/+           |
    # | 2560 x 1440  | 88.8 / 60.0  | 241.5       | +/-           |
    # | 3840 x 1600  | 98.8 / 60.0  | 395         | +/-           |
    services.xserver.monitorSection = ''
      VendorName  "Unknown"
      ModelName   "DELL U3818DW"
      HorizSync    25.0 - 115.0
      VertRefresh  24.0 - 85.0
      Option      "DPMS"
    '';

    services.xserver.deviceSection = ''
      BoardName   "NVIDIA RTX A4000"
    '';

    services.xserver.screenSection = ''
      DefaultDepth    24
      Option         "Stereo" "0"
      Option         "nvidiaXineramaInfoOrder" "DFP-0"
      Option         "metamodes" "DP-0: nvidia-auto-select +2560+1135, DP-2: nvidia-auto-select +0+0"
      Option         "SLI" "Off"
      Option         "MultiGPU" "Off"
      Option         "BaseMosaic" "off"
      SubSection     "Display"
          Depth       24
      EndSubSection
    '';
  };
}
