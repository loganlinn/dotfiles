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
    bandwhich # display current network utilization by process
    gcc
    cached-nix-shell
    sysz
    trash-cli
    xdg-utils
    handlr # better xdg-utils (xdg-open, etc) [https://github.com/chmln/handlr]
    (writeShellScriptBin "open" ''exec ${handlr}/bin/handlr open "$@"'')
    (writeShellScriptBin ''CAPSLOCK'' ''${xdotool}/bin/xdotool key Caps_Lock'') # just in case ;)
  ];

  xdg.configFile."handlr/handlr.toml".text = ''
    enable_selector = true
    selector = "${config.programs.rofi.finalPackage} -dmenu -i -p 'Open With: '"
  '';
}
