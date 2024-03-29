{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isLinux {
  home.keyboard = {
    layout = "us";
    options = ["ctrl:nocaps" "compose:ralt"];
  };

  home.packages = with pkgs; [
    gcc
    cached-nix-shell
    usbutils # usb-devices
    sysz
    trashy
    xdg-utils
    handlr # better xdg-utils (xdg-open, etc) [https://github.com/chmln/handlr]
    (writeShellScriptBin "open" ''exec ${handlr}/bin/handlr open "$@"'')
    (writeShellScriptBin ''CAPSLOCK'' ''${xdotool}/bin/xdotool key Caps_Lock'') # just in case ;)
  ];

  # xdg.configFile."handlr/handlr.toml".text = ''
  #   enable_selector = true
  #   selector = "${config.programs.rofi.finalPackage}/bin/rofi -dmenu -i -p 'Open With: '"
  # '';
}
