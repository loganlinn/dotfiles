{ config, lib, pkgs, ... }:

# with lib;

let
  inherit (builtins)
    isNull
    toString
    ;
  inherit (lib)
    mkIf
    optionalString
    ;

  themeCfg = config.modules.theme;

  # common module gen function
  module = type: config: {
    inherit type;
    background = "\${colors.background}";
    foreground = "\${colors.foreground}";
    format-background = "\${colors.background}";
    format-foreground = "\${colors.foreground}";
    format-prefix-foreground = "\${colors.foreground-dark}";
    format-suffix-foreground = "\${colors.foreground-dark}";
    format-padding = 2;
  } // config;

  polybar-msg = "${config.services.polybar.package}/bin/polybar-msg";

in
{
  config = mkIf config.services.polybar.enable {

    # HACK: setup PATH for scripts
    systemd.user.services.polybar.Service.Environment =
      let path = lib.strings.makeBinPath [
        "/run/wrappers"
        "${config.home.homeDirectory}/.nix-profile"
        "/etc/profiles/per-user/${config.home.username}"
        "/nix/var/nix/profiles/default"
        "/run/current-system/sw"
        "${config.home.homeDirectory}/.dotfiles"
        "${config.home.homeDirectory}/.dotfiles/local"
        "${pkgs.coreutils}"
        "${pkgs.bash}"
        "${pkgs.procps}"
      ];
      in
      lib.mkForce "PATH=${path}";

    systemd.user.services.polybar.Install.WantedBy = [ "graphical-session.target" ];

    services.polybar = {

      package = pkgs.polybarFull;

      script = ''
        # Terminate all running polybar instances.
        polybar-msg cmd quit 2>/dev/null || true

        for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1); do
          MONITOR=$m polybar --log=info --reload main &
        done
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

        colors = (lib.mapAttrs (k: v: "#${v}") config.colorScheme.colors) // {
          background = "\${colors.base00}";
          background-alt = "\${colors.base01}";
          background-selection = "\${colors.base02}";
          background-highlight = "\${colors.base03}";
          foreground-dark = "\${colors.base03}";
          foreground = "\${colors.base04}";
          foreground-light = "\${colors.base05}";
          primary = "\${colors.base0D}";
          secondary = "\${colors.base0A}";
          ok = "\${colors.base0B}"; # i.e. diff added
          warn = "\${colors.base0E}"; # i.e. diff changed
          alert = "\${colors.base08}"; # i.e. diff deleted
        };

        "global/wm" = {
          margin-top = 2;
          margin-bottom = 2;
        };

        "bar/main" = {
          monitor = "\${env:MONITOR:}";
          monitor-fallback = "";
          monitor-strict = false;

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

          # font-N = <fontconfig pattern>;<vertical offset>
          font-0 = "${themeCfg.fonts.mono.name}:size=10;3";
          font-1 = "${themeCfg.fonts.mono.name}:size=10:style=Bold;3";
          font-2 = "Font Awesome 6 Free:style=Solid:pixelsize=12;2";
          font-3 = "Font Awesome 6 Free:style=Regular:pixelsize=12;2";
          font-4 = "Font Awesome 6 Brands:pixelsize=12;2";
          font-5 = "Symbols Nerd Font:size=15;4";
          font-6 = "Material Design Icons:pixelsize=13;3";

          bottom = false;
          fixed-center = true;
          width = "100%";
          height = 36;
          offset-x = 0;
          offset-y = 0;
          radius = 0;

          background = "\${colors.background}";
          foreground = "\${colors.foreground}";

          line-size = 2;
          line-color = "\${colors.primary}";

          border-size = 0;
          border-color = "\${colors.background-alt}";

          separator = " "; # https://en.wikipedia.org/wiki/Thin_space
          separator-background = "\${colors.background-alt}";
          separator-foreground = "\${colors.foreground-light}";

          tray-position = "\${env:TRAY_POSITION:none}";
          tray-padding = 2;
          tray-maxsize = 18;
          tray-detached = false;
          tray-background = "\${colors.background}";

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
          format-volume-background = "\${colors.background}";
          format-volume-foreground = "\${colors.foreground}";
          format-volume-padding = 2;
          format-muted = "<label-muted>";
          format-muted-prefix = "";
          format-muted-prefix-font = 3;
          format-muted-background = "\${colors.warn}";
          format-muted-foreground = "\${colors.background}";
          format-muted-padding = 2;
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
          label = "%title%";
          label-maxlen = 50;
          label-empty = "Empty";
          label-empty-foreground = "\${colors.foreground-dark}";
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
          label-focused-background = "\${colors.background-alt}";
          label-focused-foreground = "\${colors.primary}";
          label-focused-underline = "\${colors.primary}";
          label-focused-padding = 1;

          label-mode = "%mode%";
          # label-mode-background = "\${colors.base01}";
          # label-mode-foreground = "\${colors.base05}";
          # label-mode-underline = "\${colors.primary}";
          label-mode-background = "\${colors.secondary}";
          label-mode-foreground = "\${colors.background-alt}";
          label-mode-padding = 1;

          label-unfocused = "%name%";
          # label-unfocused-background = "\${colors.base00}";
          # label-unfocused-foreground = "\${colors.base03}";
          label-unfocused-padding = 1;

          label-urgent = "%name%";
          label-urgent-padding = 1;
          label-urgent-background = "\${colors.alert}";
          label-urgent-foreground = "\${colors.background}";
          # label-urgent-foreground = "\${colors.base07}";
          # label-urgent-background = "\${colors.base03}";
          # label-urgent-underline = "\${colors.base0A}";

          # label-visible = "%icon%";
          label-visible = "%name%";
          # label-visible-background = "\${colors.base00}";
          # label-visible-foreground = "\${colors.base05}";
          label-visible-foreground = "\${colors.secondary}";
          label-visible-padding = 1;
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
          bar-used-foreground-0 = "\${colors.ok}";
          bar-used-foreground-1 = "\${colors.ok}";
          bar-used-foreground-2 = "\${colors.ok}";
          bar-used-foreground-3 = "\${colors.warn}";
          bar-used-foreground-4 = "\${colors.warn}";
          bar-used-foreground-5 = "\${colors.alert}";
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
          bar-load-foreground-0 = "\${colors.ok}";
          bar-load-foreground-1 = "\${colors.ok}";
          bar-load-foreground-2 = "\${colors.ok}";
          bar-load-foreground-3 = "\${colors.warn}";
          bar-load-foreground-4 = "\${colors.warn}";
          bar-load-foreground-5 = "\${colors.alert}";
          bar-load-indicator = "|";
          bar-load-indicator-foreground = "#ff";
          bar-load-fill = "┅";
          bar-load-empty = "┅";
          bar-load-empty-foreground = "\${colors.base04}";
          ramp-load-spacing = 0;
          ramp-load-0-foreground = "\${colors.ok}";
          ramp-load-1-foreground = "\${colors.ok}";
          ramp-load-2-foreground = "\${colors.ok}";
          ramp-load-3-foreground = "\${colors.warn}";
          ramp-load-4-foreground = "\${colors.warn}";
          ramp-load-5-foreground = "\${colors.warn}";
          ramp-load-6-foreground = "\${colors.warn}";
          ramp-load-7-foreground = "\${colors.alert}";
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
          format-warn-foreground = "\${colors.foreground}";
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
          ramp-0-foreground = "\${colors.ok}";
          ramp-1-foreground = "\${colors.ok}";
          ramp-2-foreground = "\${colors.ok}";
          ramp-3-foreground = "\${colors.warn}";
          ramp-4-foreground = "\${colors.warn}";
          ramp-5-foreground = "\${colors.warn}";
          ramp-6-foreground = "\${colors.warn}";
          ramp-7-foreground = "\${colors.alert}";
        };

        "module/dunst" =
          let
            dunst-module = pkgs.writeShellScriptBin "dunst-module" ''
              # readonly SPACER="   "

              function printActive() {
                echo -n "%{B$ACTIVE_BG}"
                echo -n "%{F$ACTIVE_FG}"
                echo -n '  '
              }

              function printPaused() {
                local num_waiting
                num_waiting=$(dunstctl count waiting)

                echo -n "%{B$PAUSED_BG}"
                echo -n "%{F$PAUSED_FG}"
                echo -n '  '
                (( num_waiting == 0 )) || echo -n "($num_waiting) "
              }

              while :; do
                echo -n '%{A1:dunstctl set-paused toggle:}' # left click
                echo -n '%{A2:dunstctl close-all:}'         # middle click
                echo -n '%{A3:dunstctl context:}'           # right click
                echo -n '%{A4:dunstctl close:}'             # scroll up
                echo -n '%{A5:dunstctl history-pop:}'       # scroll down
                echo -n '%{T3}'
                if [[ $(dunstctl is-paused) != "true" ]]; then
                  printActive
                else
                  printPaused
                fi
                echo -n '%{A}'
                echo -n '%{A}'
                echo -n '%{A}'
                echo -n '%{A}'
                echo -n '%{A}'
                echo
                sleep 1
              done
            '';
            # };
          in
          {
            type = "custom/script";
            exec = "${dunst-module}/bin/dunst-module";
            tail = true;
            env-ACTIVE_FG = "\${colors.foreground}";
            env-ACTIVE_BG = "\${colors.background}";
            env-PAUSED_FG = "\${colors.background-alt}";
            env-PAUSED_BG = "\${colors.warn}";
          };
      };
    };

    # extraConfig = ''
    #   ${let extraConfigDir = "${config.xdg.configHome}/polybar/config.d"; in
    #     lib.optionalString (lib.pathExists extraConfigDir)
    #       "include-directory = ${extraConfigDir}"}
    # '';
  };
}
