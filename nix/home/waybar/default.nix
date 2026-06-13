{
  config,
  lib,
  pkgs,
  ...
}: let
  palette = config.colorScheme.palette;
in {
  programs.waybar = {
    enable = lib.mkDefault true;
    systemd.enable = lib.mkDefault false; # started by Hyprland exec-once

    settings = [
      {
        layer = "top";
        position = "top";
        spacing = 0;
        height = 26;
        reload_style_on_change = true;

        modules-left = ["hyprland/workspaces"];
        modules-center = ["clock"];
        modules-right = [
          "tray"
          "bluetooth"
          "network"
          "wireplumber"
          "cpu"
          "battery"
        ];

        "hyprland/workspaces" = {
          on-click = "activate";
          format = "{icon}";
          format-icons = {
            default = "";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "0";
            active = "\uf444"; # 󱓻
          };
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
          };
        };

        clock = {
          format = "{:%A %H:%M}";
          format-alt = "{:%d %B W%V %Y}";
          tooltip = false;
        };

        wireplumber = {
          format = "";
          format-muted = "󰝟";
          scroll-step = 5;
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          tooltip-format = "Playing at {volume}%";
          max-volume = 150;
        };

        network = {
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          format = "{icon}";
          format-wifi = "{icon}";
          format-ethernet = "󰀂";
          format-disconnected = "󰤮";
          tooltip-format-wifi = "{essid} ({frequency} GHz)";
          tooltip-format-ethernet = "Connected";
          tooltip-format-disconnected = "Disconnected";
          interval = 3;
          on-click = "nm-connection-editor";
        };

        bluetooth = {
          format = "";
          format-off = "󰂲";
          format-disabled = "󰂲";
          format-connected = "󰂱";
          format-no-controller = "";
          tooltip-format = "Devices connected: {num_connections}";
          on-click = "blueberry";
        };

        cpu = {
          interval = 5;
          format = "󰍛";
          on-click = "ghostty -e btop";
        };

        battery = {
          interval = 5;
          format = "{capacity}% {icon}";
          format-discharging = "{icon}";
          format-charging = "{icon}";
          format-plugged = "";
          format-full = "󰂅";
          format-icons = {
            charging = ["󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
            default = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          };
          tooltip-format-discharging = "{power:>1.0f}W\u2193 {capacity}%";
          tooltip-format-charging = "{power:>1.0f}W\u2191 {capacity}%";
          states = {
            warning = 20;
            critical = 10;
          };
        };

        tray = {
          icon-size = 12;
          spacing = 17;
        };
      }
    ];

    style = ''
      @define-color base00 #${palette.base00};
      @define-color base01 #${palette.base01};
      @define-color base02 #${palette.base02};
      @define-color base03 #${palette.base03};
      @define-color base04 #${palette.base04};
      @define-color base05 #${palette.base05};
      @define-color base06 #${palette.base06};
      @define-color base07 #${palette.base07};
      @define-color base08 #${palette.base08};
      @define-color base09 #${palette.base09};
      @define-color base0A #${palette.base0A};
      @define-color base0B #${palette.base0B};
      @define-color base0C #${palette.base0C};
      @define-color base0D #${palette.base0D};
      @define-color base0E #${palette.base0E};
      @define-color base0F #${palette.base0F};

      * {
        background-color: @base00;
        color: @base05;
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: '${config.my.fonts.mono.name}', 'Symbols Nerd Font';
        font-size: 12px;
      }

      window#waybar {
        background-color: @base00;
        color: @base05;
      }

      .modules-left {
        margin-left: 8px;
      }

      .modules-right {
        margin-right: 8px;
      }

      #workspaces button {
        all: initial;
        padding: 0 6px;
        margin: 0 1.5px;
        min-width: 9px;
        color: @base05;
      }

      #workspaces button.empty {
        opacity: 0.5;
      }

      #workspaces button.active {
        color: @base0D;
      }

      #workspaces button.urgent {
        color: @base08;
      }

      #cpu,
      #battery,
      #wireplumber,
      #bluetooth,
      #network {
        min-width: 12px;
        margin: 0 7.5px;
      }

      #tray {
        margin-right: 16px;
      }

      #bluetooth {
        margin-right: 17px;
      }

      #network {
        margin-right: 13px;
      }

      #clock {
        margin-left: 8.75px;
      }

      #battery.warning {
        color: @base0A;
      }

      #battery.critical {
        color: @base08;
      }

      tooltip {
        background-color: @base01;
        color: @base05;
        border: 1px solid @base03;
        border-radius: 4px;
        padding: 2px;
      }

      tooltip label {
        color: @base05;
        padding: 2px;
      }
    '';
  };
}
