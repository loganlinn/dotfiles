{ config, lib, pkgs, ... }:

# with lib;

let
  inherit (builtins)
    isNull
    toString
    ;
  inherit (lib)
    optionalString
    ;

  # Helpers for format tags
  # - https://github.com/polybar/polybar/wiki/Formatting
  # - https://github.com/LemonBoy/bar#formatting
  withBackground = color: text: "%{B${color}}${text}%{B-}";
  withForeground = color: text: "%{F${color}}${text}%{F-}";
  withUnderline = color: text: "%{u${color}}%{+u}${text}%{u-}";
  withOverline = color: text: "%{o${color}}%{+o}${text}%{o-}";
  withReverse = text: "%{R}${text}%{R}";
  withFont = index: text: "%{T${index}}${text}%{T-}"; # NOTE: 1-based indexing
  withOffset = size: text: "%{O${size}}${text}";
  withRightAlign = text: "%{r}${text}%{r-}";
  withCenterAlign = text: "%{c}${text}%{c-}";
  withLeftAlign = text: "%{l}${text}%{l-}";
  withAction = button: command: text: "%{A${builtins.toString button}:${lib.escape [":"] command}:}${text}%{A}";
  withLeftClick = withAction 1;
  withMiddleClick = withAction 2;
  withRightClick = withAction 3;
  withScrollUp = withAction 4;
  withScrollDown = withAction 5;
  withDoubleLeftClick = withAction 6;
  withDoubleMiddleClick = withAction 7;
  withDoubleRightClick = withAction 8;

  # common module gen function
  module = type: config: {
    inherit type;
    background = "\${colors.base00}";
    foreground = "\${colors.base06}";
    format-padding = 2;
    format-prefix-foreground = "\${colors.base04}";
    format-suffix-foreground = "\${colors.base04}";
    format-background = "\${colors.base00}";
    format-foreground = "\${colors.base06}";
  } // config;

  polybar-msg = "${config.services.polybar.package}/bin/polybar-msg";

in
{
  systemd.user.services.polybar = {
    Install.WantedBy = [ "graphical-session.target" ];
  };

  services.polybar = {

    package = pkgs.polybarFull;

    script = ''
      polybar --log=trace "$(${pkgs.nettools}/bin/hostname)" 2>&1 | tee /tmp/polybar.log &
    '';

    config = {

      settings = {
        screenchange-reload = true;
        pseudo-transparency = !config.services.picom.enable;
        compositing-background = "source";
        compositing-foreground = "over";
        compositing-overline = "over";
        compositing-underline = "over";
        compositing-border = "over";
      };

      colors = lib.mapAttrs (k: v: "#${v}") config.colorScheme.colors;

      "global/wm" = {
        margin-top = 2;
        margin-bottom = 2;
      };

      "bar/nijusan" = {
        modules-left = [
          "i3"
        ];
        modules-center = [
          "title"
        ];
        modules-right = [
          "memory"
          "cpu"
          "temperature"
          "pulseaudio"
          "dunst"
          "date"
        ];

        # tray-position = "right";
        tray-position = "none";
        tray-padding = 2;
        tray-detached = false;
        tray-maxsize = 18;

        width = "100%";
        height = "36";
        bottom = false;
        radius = 0;

        font-size = "10";
        # padding = 1;
        # module-margin = 1;
        line-size = 2;
        separator = " "; # https://en.wikipedia.org/wiki/Thin_space
        separator-background = "\${colors.base01}";

        font-0 = "${config.modules.theme.fonts.mono.name}:size=10;3";
        font-1 = "${config.modules.theme.fonts.mono.name}:size=10:style=Bold;3";
        font-2 = "Font Awesome:size=12;2";

        cursor-click = "pointer"; # hand
        cursor-scroll = "ns-resize"; # arrows

        enable-ipc = true;
      };

      # "bar/bottom" = {
      #   width = "100%";
      #   height = "32";
      #   radius = "4.0";
      #   bottom = false;
      #   enable-ipc = true;
      #   modules-center = [ "date" ];
      # };

      "module/pulseaudio" = module "internal/pulseaudio" {
        interval = 5;
        use-ui-max = false; # use PA_VOLUME_NORM (100%)
        format-volume = "<ramp-volume> <label-volume>";
        format-volume-background = "\${colors.base00}";
        format-volume-foreground = "\${colors.base06}";
        format-volume-padding = 3;
        format-muted = "<label-muted>";
        format-muted-prefix = "";
        format-muted-prefix-font = 3;
        format-muted-background = "\${colors.base09}";
        format-muted-foreground = "\${colors.base01}";
        format-muted-padding = 3;
        label-muted = " MUTED";
        label-volume = "%percentage%%";
        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";
        ramp-volume-3 = "";
        ramp-volume-0-font = 3;
        ramp-volume-1-font = 3;
        ramp-volume-2-font = 3;
        ramp-volume-3-font = 3;
        click-right = "${pkgs.pavucontrol}/bin/pavucontrol &";
      };

      "module/title" = module "internal/xwindow" {
        format = "<label>";
        format-padding = 4;
        label = "%title%";
        label-maxlen = 50;
        label-empty = "Empty";
        label-empty-foreground = "\${colors.base02}";
      };

      # Module settings (https://github.com/polybar/polybar/wiki/Configuration#module-settings)
      "module/i3" = module "internal/i3" {
        enable-click = true;
        enable-scroll = false;
        index-sort = true; # Sort the workspaces by index instead by output
        pin-workspaces = false; # only show workspaces on the current monitor
        show-urgent = true; # Show urgent workspaces regardless of whether the workspace is hidden by pin-workspaces.
        strip-wsnumbers = true; # Split the workspace name on ':'
        fuzzy-match = true; # Use fuzzy (partial) matching on labels when assigning icons to workspaces

        format = "<label-state> <label-mode>";
        label-focused = "%name%";
        label-focused-background = "\${colors.base01}";
        label-focused-foreground = "\${colors.base0D}";
        label-focused-underline = "\${colors.base0D}";
        label-focused-font = 2;
        label-focused-padding = 2;

        label-mode = "%mode%";
        label-mode-background = "\${colors.base01}";
        label-mode-foreground = "\${colors.base05}";
        label-mode-underline = "\${colors.base09}";
        label-mode-font = 1;
        label-mode-padding = 2;

        label-unfocused = "%name%";
        label-unfocused-background = "\${colors.base00}";
        label-unfocused-foreground = "\${colors.base03}";
        label-unfocused-font = 1;
        label-unfocused-padding = 2;

        label-urgent = "%name%";
        label-urgent-padding = 2;
        label-urgent-foreground = "\${colors.base07}";
        label-urgent-background = "\${colors.base03}";
        label-urgent-underline = "\${colors.base0A}";

        label-visible = "%name%";
        label-visible-background = "\${colors.base00}";
        label-visible-foreground = "\${colors.base05}";
        label-visible-padding = 2;
      };

      "module/date" = module "internal/date" {
        interval = 1;
        time = "%I:%M %p";
        date = "%a %b %d";
        time-alt = "%H:%M";
        date-alt = " %Y-%m-%d%";
        format = "<label>";
        # format-prefix = " ";
        label = "%date% %time%";
      };

      "module/memory" = module "internal/memory" {
        interval = 2;
        format = "<label> <bar-used>";
        label = "%percentage_used%%";
        format-prefix = "RAM ";
        bar-used-width = 6;
        bar-used-foreground-0 = "\${colors.base0B}";
        bar-used-foreground-1 = "\${colors.base0B}";
        bar-used-foreground-2 = "\${colors.base0B}";
        bar-used-foreground-3 = "\${colors.base0A}";
        bar-used-foreground-4 = "\${colors.base09}";
        bar-used-foreground-5 = "\${colors.base08}";
        bar-used-indicator = "|";
        bar-used-indicator-foreground = "#ff";
        bar-used-fill = "┅";
        bar-used-empty = "┅";
        bar-used-empty-foreground = "\${colors.base04}";
      };

      "module/gpu" = module "custom/script" {
        exec = ''
          /run/current-system/sw/bin/nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | ${pkgs.gawk}/bin/awk '{ print $1 "%"}'
        '';
        interval = 5;
        format-prefix = "GPU ";
      };

      "module/cpu" = module "internal/cpu" {
        interval = 2;
        format-prefix = "CPU ";
        format = "<label> <bar-load>";
        # format = "<label> <bar-load>";
        label = "%percentage%%";
        bar-load-width = 6;
        bar-load-foreground-0 = "\${colors.base0B}";
        bar-load-foreground-1 = "\${colors.base0B}";
        bar-load-foreground-2 = "\${colors.base0B}";
        bar-load-foreground-3 = "\${colors.base0A}";
        bar-load-foreground-4 = "\${colors.base09}";
        bar-load-foreground-5 = "\${colors.base08}";
        bar-load-indicator = "|";
        bar-load-indicator-foreground = "#ff";
        bar-load-fill = "┅";
        bar-load-empty = "┅";
        bar-load-empty-foreground = "\${colors.base04}";
        ramp-load-spacing = 0;
        ramp-load-0-foreground = "\${colors.base0B}";
        ramp-load-1-foreground = "\${colors.base0B}";
        ramp-load-2-foreground = "\${colors.base0B}";
        ramp-load-3-foreground = "\${colors.base0A}";
        ramp-load-4-foreground = "\${colors.base0A}";
        ramp-load-5-foreground = "\${colors.base09}";
        ramp-load-6-foreground = "\${colors.base09}";
        ramp-load-7-foreground = "\${colors.base08}";
        ramp-load-0 = "▁";
        ramp-load-1 = "▂";
        ramp-load-2 = "▃";
        ramp-load-3 = "▄";
        ramp-load-4 = "▅";
        ramp-load-5 = "▆";
        ramp-load-6 = "▇";
        ramp-load-7 = "█";
      };

      "module/temperature" = module "internal/temperature" {
        interval = 5;
        thermal-zone = "x86_pkg_temp";
        hwmon-path = "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp1_input";
        base-temperature = 50;
        warn-temperature = 75;
        units = true;
        format-prefix = "TEMP ";
        format = "<label> <ramp>";
        format-warn = "<label-warn> <ramp>";
        format-warn-background = "\${colors.base00}";
        format-warn-foreground = "\${colors.base06}";
        format-warn-padding = 2;
        label = "%temperature-c%";
        label-warn = "%temperature-c%";
        ramp-0 = "";
        ramp-1 = "";
        ramp-2 = "";
        ramp-3 = "";
        ramp-4 = "";
        ramp-5 = "";
        ramp-6 = "";
        ramp-7 = "";
        ramp-0-foreground = "\${colors.base0B}";
        ramp-1-foreground = "\${colors.base0B}";
        ramp-2-foreground = "\${colors.base0B}";
        ramp-3-foreground = "\${colors.base0A}";
        ramp-4-foreground = "\${colors.base0A}";
        ramp-5-foreground = "\${colors.base09}";
        ramp-6-foreground = "\${colors.base09}";
        ramp-7-foreground = "\${colors.base08}";
      };

      "module/dunst" =
        let
          dunst-module = pkgs.writeShellApplication {
            name = "dunst-module";

            runtimeInputs = [
              config.services.polybar.package # polybar-msg
              config.services.dunst.package # dunstctl
              pkgs.dbus # dbus-send (needed by dunstctl)
              pkgs.procps # pgrep
              pkgs.coreutils # sleep
            ];

            text = ''
              readonly SPACER="   "

              function printActive() {
                echo -n '%{A1:dunstctl set-paused toggle:}' # left click
                echo -n '%{A2:dunstctl close-all:}'         # middle click
                echo -n '%{A3:dunstctl context:}'           # right click
                echo -n '%{A4:dunstctl close:}'             # scroll up
                echo -n '%{A5:dunstctl history-pop:}'       # scroll down
                echo -n '%{T3}'
                echo -n '%{B#${config.colorScheme.colors.base00}}'
                echo -n '%{F#${config.colorScheme.colors.base06}}'
                echo -n "$SPACER"
                echo -n ''
                echo -n "$SPACER"
                echo -n '%{A}'
                echo -n '%{A}'
                echo -n '%{A}'
                echo -n '%{A}'
                echo -n '%{A}'
              }

              function printPaused() {
                local num_waiting
                num_waiting=$(dunstctl count waiting)

                echo -n '%{A1:dunstctl set-paused toggle:}' # left click
                echo -n '%{T3}'
                echo -n '%{B#${config.colorScheme.colors.base0E}}'
                echo -n '%{F#${config.colorScheme.colors.base01}}'
                echo -n "$SPACER"
                echo -n ''
                (( num_waiting == 0 )) || echo -n " ($num_waiting)"
                echo -n "$SPACER"
                echo -n '%{A}'
              }

              while :; do
                if [[ $(dunstctl is-paused) != "true" ]]; then
                  printActive
                else
                  printPaused
                fi
                echo
                sleep 1
              done
            '';
          };
        in
        {
          type = "custom/script";
          exec = "${dunst-module}/bin/dunst-module";
          tail = true;
          label-alignment = "center";
        };
    };
  };

  # extraConfig = ''
  #   ${let extraConfigDir = "${config.xdg.configHome}/polybar/config.d"; in
  #     lib.optionalString (lib.pathExists extraConfigDir)
  #       "include-directory = ${extraConfigDir}"}
  # '';
}
