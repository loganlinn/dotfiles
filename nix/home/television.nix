{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  xdg.configFile."television/cable".source =
    mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/television/cable";

  programs.television = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      ui = {
        use_nerd_font_icons = true;
      };
      keybindings = {
        quit = [
          "esc"
          "ctrl-c"
        ];
      };
    };
  };
}
