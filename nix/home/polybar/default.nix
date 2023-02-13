{ config, lib, pkgs, ... }:

with lib;

let
  colorsHex = mapAttrs (k: v: "#${v}") config.colorScheme.colors;
in
{
  systemd.user.services.polybar = {
    Install.WantedBy = [ "graphical-session.target" ];
  };

  services.polybar = {
    enable = mkDefault true;

    package = pkgs.polybarFull;

    config =
      let
        module = name: config: {
          name = "module/${name}";
          value = {
            type =
              if (hasAttr "exec" config) then
                "custom/script"
              else
                "internal/${name}";

            format-padding = 1;
            format-prefix-foreground = colorsHex.base06;
          } // config;
        };
      in
      {
        # Application settings (https://github.com/polybar/polybar/wiki/Configuration#application-settings)
        settings = { screenchange-reload = true; };

        # Custom variables (https://github.com/polybar/polybar/wiki/Configuration#custom-variables)
        colors = colorsHex // {
          background = colorsHex.base00;
          foreground = colorsHex.base05;
          focused-background = colorsHex.base02;
          focused-foreground = colorsHex.base0A;
          focused-underline = colorsHex.base0A;
          mode-background = colorsHex.base0E;
          mode-foreground = colorsHex.base02;
          separator-background = colorsHex.base00;
          separator-foreground = colorsHex.base01;
          unfocused-background = colorsHex.base00;
          unfocused-foreground = colorsHex.base03;
          urgent-background = colorsHex.base00;
          urgent-foreground = colorsHex.base08;
          visible-background = colorsHex.base02;
          visible-foreground = colorsHex.base0C;
          warning-foreground = colorsHex.base0E;
          error-foreground = colorsHex.base08;
          muted-foreground = colorsHex.base0E;
        };

        # Bar settings (https://github.com/polybar/polybar/wiki/Configuration#bar-settings)
        bar = {
          fill = "⏽";
          empty = "⏽";
          indicator = "⏽";
        };
        "bar/top" = {
          monitor = "\${env:MONITOR:}"; # see script
          width = "100%";
          height = "36";
          bottom = false;
          enable-ipc = true;
          radius = 0;
          font-size = "12";
          font-0 = "${config.modules.theme.fonts.mono.name}:size=10;3";
          font-1 = "${config.modules.theme.fonts.mono.name}:size=10:style=Bold;3";
          font-2 = "Font Awesome:size=12;2";
          font-3 = "Symbols-Nerd-Font:size=20;3";
          padding = 3;
          # separator = " ";
          module-margin = 1;

          modules-left = [ "i3" ];
          modules-center = [ "title" ];
          modules-right = [ "memory" "cpu" "temperature" "pulseaudio" "dunst-snooze" "date" ];

          tray-position = "right";
          tray-detached = false;
          tray-maxsize = 16;

          background = "\${colors.base00}";
          foreground = "\${colors.base05}";

          cursor-click = "pointer"; # hand
          cursor-scroll = "ns-resize"; # arrows

          line-size = 2;
        };
        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          interval = 5;
          use-ui-max = false; # use PA_VOLUME_NORM (100%)
          format-volume = "<ramp-volume> <label-volume>";
          format-muted = "<label-muted>";
          format-muted-prefix = "  ";
          format-muted-prefix-font = 3;
          format-muted-background = "\${colors.background}";
          format-muted-padding = 1;
          format-muted-prefix-foreground = "\${colors.base0E}";
          label-muted = " Muted";
          label-muted-foreground = "\${colors.base0E}";
          label-volume = "%percentage%%";
          label-volume-foreground = "\${colors.base05}";
          ramp-volume-0 = "  ";
          ramp-volume-1 = "  ";
          ramp-volume-2 = "  ";
          ramp-volume-3 = "  ";
          ramp-volume-0-font = 3;
          ramp-volume-1-font = 3;
          ramp-volume-2-font = 3;
          ramp-volume-3-font = 3;
          click-right = "${pkgs.pavucontrol}/bin/pavucontrol &";
        };
        "module/title" = {
          type = "internal/xwindow";
          format = "<label>";
          format-background = "\${colors.base00}";
          format-foreground = "\${colors.base06}";
          format-padding = 4;
          label = "%title%";
          label-maxlen = 50;
          label-empty = "Empty";
          label-empty-foreground = "\${colors.base02}";
        };
      } // listToAttrs [
        # Module settings (https://github.com/polybar/polybar/wiki/Configuration#module-settings)
        (module "i3" {
          enable-click = true;
          enable-scroll = false;
          wrapping-scroll = false; # Wrap around when reaching the first/last workspace
          reverse-scroll = false;
          index-sort = true; # Sort the workspaces by index instead by output
          pin-workspaces = false; # only show workspaces on the current monitor
          show-urgent = true; # Show urgent workspaces regardless of whether the workspace is hidden by pin-workspaces.
          strip-wsnumbers = true; # Split the workspace name on ':'
          fuzzy-match = true; # Use fuzzy (partial) matching on labels when assigning icons to workspaces
          # Available tags:
          #   <label-state> (default) - gets replaced with <label-(focused|unfocused|visible|urgent)>
          #   <label-mode> (default)
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

          # label-separator-background = "\${colors.separator-background}";
          # label-separator-foreground = "\${colors.separator-foreground}";
          # label-separator-font = 1;
          # label-separator-padding = 0;

        })
        (module "date" {
          interval = 1;
          time = "%I:%M %p";
          date = "%a %b %d";
          format-prefix = " ";
          label = "%date% %time%";
          label-font = 6;
        })
        (module "memory" {
          interval = 2;
          format = "<label> <bar-used>";
          label = "%percentage_used%%";
          format-prefix = "RAM ";
          bar-used-width = 10;
          bar-used-foreground-0 = "\${colors.base0B}";
          bar-used-foreground-1 = "\${colors.base0B}";
          bar-used-foreground-2 = "\${colors.base0B}";
          bar-used-foreground-3 = "\${colors.base0A}";
          bar-used-foreground-4 = "\${colors.base09}";
          bar-used-foreground-5 = "\${colors.base08}";
          bar-used-indicator = "|";
          bar-used-indicator-foreground = "#ff";
          bar-used-fill = "─";
          bar-used-empty = "─";
          bar-used-empty-foreground = "#444444";
        })
        (module "gpu" {
          exec =
            let
              awk = "${pkgs.gawk}/bin/awk";
              nvidia-smi = "/run/current-system/sw/bin/nvidia-smi";
            in
            ''
              ${nvidia-smi} --query-gpu=utilization.gpu --format=csv,noheader,nounits | ${awk} '{ print $1 "%"}'
            '';
          interval = 5;
          # format-prefix = "%{T7} %{T-}";
          format-prefix = "GPU ";
        })
        (module "cpu" {
          interval = 2;
          # format-prefix = "%{T7} %{T-}";
          format-prefix = "CPU ";
          format = "<label> <bar-load>";
          label = "%percentage%%";
          bar-load-width = 10;
          bar-load-foreground-0 = "\${colors.base0B}";
          bar-load-foreground-1 = "\${colors.base0B}";
          bar-load-foreground-2 = "\${colors.base0B}";
          bar-load-foreground-3 = "\${colors.base0A}";
          bar-load-foreground-4 = "\${colors.base09}";
          bar-load-foreground-5 = "\${colors.base08}";
          bar-load-indicator = "|";
          bar-load-indicator-foreground = "#ff";
          bar-load-fill = "─";
          bar-load-empty = "─";
          bar-load-empty-foreground = "#444444";
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
        })
        (module "temperature" {
          interval = 5;
          thermal-zone = "x86_pkg_temp";
          hwmon-path =
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp1_input";
          base-temperature = 50;
          warn-temperature = 75;
          units = true;
          format-prefix = "TEMP ";
          format = "<ramp> <label>";
          format-warn = "<label-warn> <ramp>";
          label-warn-foreground = "\${colors.base06}";
          label = "%temperature-c%";
          ramp-0 = "";
          ramp-1 = "";
          ramp-2 = "";
          ramp-3 = "";
          ramp-4 = "";
          ramp-5 = "";
          ramp-6 = "";
          ramp-7 = "";
          # ramp-0-foreground = "\${colors.base0B}";
          # ramp-1-foreground = "\${colors.base0A}";
          # ramp-2-foreground = "\${colors.base09}";
          ramp-0-foreground = "\${colors.base0B}";
          ramp-1-foreground = "\${colors.base0B}";
          ramp-2-foreground = "\${colors.base0B}";
          ramp-3-foreground = "\${colors.base0A}";
          ramp-4-foreground = "\${colors.base0A}";
          ramp-5-foreground = "\${colors.base09}";
          ramp-6-foreground = "\${colors.base09}";
          ramp-7-foreground = "\${colors.base08}";
        })
        (
          let
            dunst-snooze = import ./dunst-snooze.nix {
              inherit pkgs;
              dunst = config.services.dunst.package;
            };
          in
          module "dunst-snooze" {
            type = "custom/script";
            exec = "${dunst-snooze}/bin/dunst-snooze";
            click-left = "${dunst-snooze}/bin/dunst-snooze toggle";
            interval = 5;
            env-COLOR_PAUSED_BG = config.colorScheme.colors.base0E;
            env-COLOR_PAUSED_FG = config.colorScheme.colors.base01;
          }
        )
        # {
        #   name = "module/powermenu";
        #   value = {
        #     type = "custom/text";
        #     content = "";
        #     click-left = "rofi-powermenu &";
        #   };
        # }
      ];

    script = ''
      polybar &
    '';
  };
}
