{
  config,
  lib,
  pkgs,
  ...
}:
let
  palette = config.colorScheme.palette;
in {
  programs.wofi = {
    enable = lib.mkDefault true;
    settings = {
      width = 600;
      height = 350;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = true;
      dynamic_lines = true;
    };
  };

  xdg.configFile."wofi/style.css" = {
    text = ''
      * {
        font-family: '${config.my.fonts.mono.name}', monospace;
        font-size: 14px;
      }

      window {
        margin: 0px;
        border: 2px solid #${palette.base0D};
        border-radius: 8px;
        background-color: #${palette.base00};
      }

      #input {
        padding: 8px 12px;
        margin: 8px;
        border: none;
        border-radius: 4px;
        color: #${palette.base05};
        background-color: #${palette.base01};
      }

      #input:focus {
        outline: none;
        box-shadow: none;
        border: none;
      }

      #inner-box {
        margin: 4px 8px;
        border: none;
        background-color: #${palette.base00};
      }

      #outer-box {
        margin: 0;
        padding: 8px;
        border: none;
        background-color: #${palette.base00};
      }

      #scroll {
        margin: 0;
        padding: 0;
        border: none;
        background-color: #${palette.base00};
      }

      #text {
        color: #${palette.base05};
        margin: 0px 4px;
      }

      #entry {
        padding: 6px;
        border-radius: 4px;
        background-color: #${palette.base00};
      }

      #entry:selected {
        background-color: #${palette.base02};
        outline: none;
        border: none;
      }

      #entry:selected #text {
        color: #${palette.base0D};
      }

      #entry image {
        margin-right: 8px;
      }
    '';
  };
}
