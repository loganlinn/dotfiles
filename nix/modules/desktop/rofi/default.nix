{ config
, options
, lib
, pkgs
, ...
}:


with lib;

{
  config = mkIf config.programs.rofi.enable {

    programs.rofi = {

      font = config.modules.theme.fonts.mono.name;

      pass.enable = true;

      plugins = mkDefault (with pkgs; [
        rofi-calc
        rofi-emoji
        rofi-file-browser
        rofi-pulse-select
      ]);
    };

    xdg.configFile."rofi".source = ./config;

    # xdg.configFile."rofi".source = pkgs.fetchFromGitHub
    #   {
    #     owner = "adi1090x";
    #     repo = "rofi";
    #     rev = "ef71554d8b7097cbce1953f56d2d06f536a5826f";
    #     hash = "sha256-RePXizq3I7+u1aJMswOhotIqTVdPhaAGZQqn51lg2jY=";
    #   } + "/files";

    home.packages = with pkgs;
      mapAttrsToList
        (name: text: writeShellApplication {
          inherit name text;
          runtimeInputs = [ config.programs.rofi.finalPackage ];
        })
        {
          rofi-launcher = ''${config.xdg.configHome}/rofi/launchers/type-4/launcher.sh'';
          rofi-powermenu = ''${config.xdg.configHome}/rofi/powermenu/type-1/powermenu.sh'';
          rofi-run = ''rofi -show run -theme ${config.programs.rofi.theme}'';
          rofi-window = ''rofi -show window -theme ${config.programs.rofi.theme}'';
          rofi-volume = ''${config.xdg.configHome}/rofi/applets/bin/volume.sh'';
          rofi-screenshot = ''${config.xdg.configHome}/rofi/applets/bin/screenshot.sh'';
        };
  };
}
