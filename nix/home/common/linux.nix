{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
  home.keyboard = {
    layout = "us";
    options = [
      "ctrl:nocaps"
      "compose:ralt"
    ];
  };

  services.xcape.enable = true;
  services.xcape.timeout = 480;
  services.xcape.mapExpression = {
    Control_L = "Escape";
  };

  home.packages = with pkgs; [
    cached-nix-shell
    gcc
    handlr # better xdg-utils (xdg-open, etc) [https://github.com/chmln/handlr]
    logger
    sysz
    trashy
    usbutils # usb-devices
    xdg-utils
    (writeShellScriptBin "open" ''exec ${handlr}/bin/handlr open "$@"'')
    (writeShellScriptBin "CAPSLOCK" "${xdotool}/bin/xdotool key Caps_Lock") # just in case ;)
  ];

  # xdg.configFile."handlr/handlr.toml".text = ''
  #   enable_selector = true
  #   selector = "${config.programs.rofi.finalPackage}/bin/rofi -dmenu -i -p 'Open With: '"
  # '';
}
