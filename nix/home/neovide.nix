{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
{
  home.packages = with pkgs; [
    nerd-fonts.victor-mono
  ];

  programs.neovide = {
    enable = mkDefault true;
    settings =
      {
        # server = "${config.xdg.cacheHome}/neovide/server.pipe";
        # https://neovide.dev/config-file.html#font
        font =
          let
            family = "VictorMono Nerd Font";
            size = 14;
          in
          {
            hinting = "full";
            edging = "antialias";
            normal = [
              {
                inherit family size;
                style = "W300";
              }
            ];
            bold = [
              {
                inherit family;
                style = "W600";
              }
            ];
            italic = [
              {
                inherit family;
                style = "Oblique";
              }
            ];
            bold_italic = [
              {
                inherit family;
                style = "Oblique W600";
              }
            ];
            features = {
              "${family}" = [
                "+ss02"
                "+ss07"
              ];
            };
          };
      }
      // optionalAttrs pkgs.stdenv.targetPlatform.isDarwin {
        frame = "buttonless";
        title-hidden = true;
      };
  };
}
