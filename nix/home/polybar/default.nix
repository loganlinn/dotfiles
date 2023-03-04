{ config, lib, pkgs, nerdfonts, ... }:

with builtins;

let
  cfg = config.modules.polybar;

  inherit (lib)
    forEach
    mkEnableOption
    mkIf
    mkOption
    optionalString
    recursiveUpdate
    types
    ;

  colors = (lib.mapAttrs (k: v: "#${v}") config.colorScheme.colors) // {
    transparent = "#00000000";
    background = "\${colors.base00}";
    background-alt = "\${colors.base01}";
    background-highlight = "\${colors.base03}";
    foreground-dark = "\${colors.base04}";
    foreground = "\${colors.base05}";
    foreground-light = "\${colors.base06}";

    highlight = "\${colors.base0A}";
    selection = "\${colors.base02}";

    primary = "\${colors.base0D}";
    secondary = "\${colors.base0C}";

    ok = "\${colors.base0B}"; # i.e. diff added
    warn = "\${colors.base0E}"; # i.e. diff changed
    alert = "\${colors.base08}"; # i.e. diff deleted

    shade0 = "#1b2229";
    shade1 = "#1c1f24";
    shade2 = "#202328";
    shade3 = "#23272e";
    shade4 = "#3f444a";
    shade5 = "#5b6268";
    shade6 = "#73797e";
    shade7 = "#9ca0a4";
    shade8 = "#dfdfdf";
  };

  # NOTE: fonts are defined with 0-indexing, but referenced with 1-indexing
  # font-N = <fontconfig pattern>;<vertical offset>
  fonts = {
    font-0 = "JetBrainsMono Nerd Font:size=10;3";
    font-1 = "JetBrainsMono Nerd Font:size=10:style=Bold;3";
    font-2 = "Symbols Nerd Font:size=12;3";
    font-3 = "Symbols Nerd Font:size=16;3";
  };

  nerdfontIcon = text: "%{T3}${text}%{T-}";
  nerdfontBigIcon = text: "%{T4}${text}%{T-}";

  # common module gen function
  mkModule = name: type: settings: {
    "module/${name}" = {
      inherit type;
      background = "\${colors.background}";
      foreground = "\${colors.foreground}";
      format-background = "\${colors.background}";
      format-foreground = "\${colors.foreground}";
      format-prefix-foreground = "\${colors.foreground-dark}";
      format-suffix-foreground = "\${colors.foreground-dark}";
      format-prefix-padding = 1;
      format-padding = 2;
    } // settings;
  };
in
{
  options.modules.polybar = {

    enable = mkEnableOption "polybar";

    package = mkOption {
      type = types.package;
      default = pkgs.polybarFull;
    };

    top.left.modules = mkOption {
      type = with types; listOf str;
      default = [ ];
    };

    top.center.modules = mkOption {
      type = with types; listOf str;
      default = [ ];
    };

    top.right.modules = mkOption {
      type = with types; listOf str;
      default = [ ];
    };

    networks = mkOption {
      type = with types; listOf attrs;
      default = [ ];
    };

    config = mkOption {
      type = types.attrs;
      default = { };
    };

    colors = mkOption {
      type = types.attrs;
      default = { };
    };

  };

  config = mkIf cfg.enable {
    services.polybar.enable = true;
    services.polybar.package = cfg.package;
    services.polybar.script = ''
      for m in $(polybar --list-monitors | ${pkgs.coreutils}/bin/cut -d":" -f1); do
        MONITOR=$m polybar top &
      done
    '';

    services.polybar.config = lib.mkMerge
      ([
        { colors = recursiveUpdate colors cfg.colors; }
        {
          settings = {
            # Reload when the screen configuration changes (XCB_RANDR_SCREEN_CHANGE_NOTIFY event)
            screenchange-reload = true;

            # Compositing operators
            # @see: https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-operator-t
            compositing-background = "source";
            compositing-foreground = "over";
            compositing-overline = "over";
            compositing-underline = "over";
            compositing-border = "over";

            # Define fallback values used by all module formats
            # format-foreground = "";
            # format-background = "";
            # format-underline = "";
            # format-overline = "";
            # format-spacing = "";
            # format-padding = "";
            # format-margin = "";
            # format-offset = "";

            pseudo-transparency = !config.services.picom.enable;
          };

          "bar/top" = fonts // {

            monitor = "\${env:MONITOR:}"; # set by script
            monitor-fallback = "";
            monitor-strict = false;

            modules-left = cfg.top.left.modules;
            modules-center = cfg.top.center.modules;
            modules-right = cfg.top.right.modules;

            bottom = false;
            fixed-center = true;
            width = "100%";
            height = 36;
            offset-x = "0%";
            offset-y = "0%";

            module-margin-left = 0;
            module-margin-right = 0;

            spacing = 0;
            padding = 0;

            separator = "";

            background = "\${colors.transparent}";
            foreground = "\${colors.foreground}";
            dim-value = "1.0";

            line-size = 3;
            line-color = "\${colors.primary}";

            # Creates a fake offset (floating bar)
            border-color = "\${colors.transparent}";
            border-top-size = 4;
            border-left-size = 6; # TODO match i3 gaps
            border-right-size = 6; # TODO match i3 gaps

            tray-position = "\${env:TRAY_POSITION:none}";
            tray-maxsize = 18;
            tray-padding = 2;
            tray-scale = "1.0";
            tray-offset-x = 0;
            tray-offset-y = 0;
            tray-detached = false;
            tray-background = "\${colors.background}";
            tray-transparent = false;

            cursor-click = "pointer"; # hand
            cursor-scroll = "ns-resize"; # arrows

            enable-ipc = true;
          };

          # "bar/top-left" = {
          #   "inherit" = "bar/top";
          #   modules-right = [ ];
          #   modules-center = [ ];
          #   width = "33%";
          #   radius = "10.0";
          # };

          # "bar/top-center" = {
          #   "inherit" = "bar/top";
          #   modules-left = [ ];
          #   modules-right = [ ];
          #   width = "33%";
          #   radius = "10.0";
          # };

          # "bar/top-right" = {
          #   "inherit" = "bar/top";
          #   modules-center = [ ];
          #   modules-left = [ ];
          #   width = "33%";
          #   radius = "10.0";
          # };
        }
        (mkModule "date" "internal/date" {
          interval = 1;
          time = "%I:%M %p";
          date = "%a %b %d";
          time-alt = "%l:%M:%S";
          date-alt = " ";
          format = "<label>";
          format-prefix = nerdfonts.md.calendar_clock;
          label = "%date% %time%";
          click-left = "eww open calendar";
        })
        (mkModule "pulseaudio" "internal/pulseaudio" {
          interval = 5;
          use-ui-max = false; # uses PA_VOLUME_NORM (maxes at 100%)

          format-volume = "<ramp-volume> <label-volume>";
          format-volume-background = "\${colors.background}";
          format-volume-foreground = "\${colors.foreground}";
          format-volume-padding = 2;
          label-volume = "%percentage%%";
          ramp-volume-0 = nerdfontBigIcon nerdfonts.md.volume_low;
          ramp-volume-1 = nerdfontBigIcon nerdfonts.md.volume_medium;
          ramp-volume-2 = nerdfontBigIcon nerdfonts.md.volume_high;
          ramp-volume-0-weight = 2;
          ramp-volume-1-weight = 3;
          ramp-volume-2-weight = 2;
          ramp-volume-foreground = "\${colors.foreground-dark}";

          format-muted = "<label-muted>";
          format-muted-prefix = nerdfontIcon nerdfonts.md.volume_off; # volume_variant_off
          format-muted-prefix-foreground = "\${colors.background}";
          format-muted-background = "\${colors.warn}";
          format-muted-foreground = "\${colors.background}";
          format-muted-padding = 2;
          label-muted = " MUTED";

          click-right = "${pkgs.pavucontrol}/bin/pavucontrol &";
        })
        (mkModule "title" "internal/xwindow" {
          format-prefix = nerdfonts.md.dock_window;
          format = "<label>";
          label = "%{A1:true && rofi -show window:} %title% %{A}";
          label-maxlen = 64;
          label-empty = "Empty";
          label-empty-foreground = "\${colors.foreground-dark}";
        })
        (mkModule "i3" "internal/i3" {
          enable-click = true;
          enable-scroll = false;
          index-sort = true; # Sort the workspaces by index instead by output
          pin-workspaces = false; # only show workspaces on the current monitor
          show-urgent = true; # Show urgent workspaces regardless of whether the workspace is hidden by pin-workspaces.
          strip-wsnumbers = true; # Split the workspace name on ':'
          fuzzy-match = true; # Use fuzzy (partial) matching on labels when assigning icons to workspaces

          format = "<label-state> <label-mode>";
          format-padding = 0;

          label-focused = "%name%";
          label-focused-background = "\${colors.background-alt}";
          label-focused-foreground = "\${colors.foreground-light}";
          label-focused-underline = "\${colors.highlight}";
          label-focused-padding = 2;

          label-mode = "%mode%";
          label-mode-background = "\${colors.warn}";
          label-mode-foreground = "\${colors.background}";
          label-mode-padding = 2;

          label-unfocused = "%name%";
          label-unfocused-background = "\${colors.background}";
          label-unfocused-foreground = "\${colors.foreground-dark}";
          label-unfocused-padding = 2;

          label-urgent = "%name%";
          label-urgent-padding = 2;
          label-urgent-background = "\${colors.alert}";
          label-urgent-foreground = "\${colors.background}";

          # label-visible = "%icon%";
          label-visible = "%name%";
          label-visible-background = "\${colors.background}";
          label-visible-foreground = "\${colors.foreground}";
          label-visible-underline = "\${colors.foreground}";
          label-visible-padding = 2;
        })
        (mkModule "i3-scratchpad" "custom/script" {
          exec = ''
            i3-msg -t get_tree | jq -r '[.. | objects | select(.scratchpad_state? == "fresh")] | length'
          '';

          format-background = "\${colors.background}";
          format-foreground = "\${colors.foreground-dark}";
          format-prefix = "+";
          format-prefix-padding = 0;
          interval = 3;
        })
        (mkModule "memory" "internal/memory" {
          interval = 2;
          format = "<label> <bar-used>";
          label = "%percentage_used%%";
          format-prefix = "RAM";
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
        })
        (mkModule "gpu" "custom/script" {
          exec = ''
            /run/current-system/sw/bin/nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | ${pkgs.gawk}/bin/awk '{ print $1 "%"}'
          '';
          interval = 5;
          format-prefix = "GPU";
        })
        (mkModule "cpu" "internal/cpu" {
          interval = 2;
          format-prefix = "CPU";
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
        })
        (mkModule "temperature" "internal/temperature" {
          interval = 5;
          thermal-zone = "x86_pkg_temp";
          hwmon-path = "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp1_input";
          base-temperature = 50;
          warn-temperature = 75;
          format-prefix = "TEMP";
          format = "<label> <ramp>";
          format-warn = "<label-warn> <ramp>";
          format-warn-background = "\${colors.base00}";
          format-warn-foreground = "\${colors.foreground}";
          format-warn-padding = 2;
          # units = false;
          # label = "%temperature-c%${nerdfonts.md.temperature_celsius}";
          # label-warn = "%temperature-c%${nerdfonts.md.temperature_celsius}";
          units = true;
          label = "%temperature-c%";
          label-warn = "%temperature-c%";
          ramp-0 = nerdfontIcon "";
          ramp-1 = nerdfontIcon "";
          ramp-2 = nerdfontIcon "";
          ramp-3 = nerdfontIcon "";
          ramp-4 = nerdfontIcon "";
          ramp-5 = nerdfontIcon "";
          ramp-6 = nerdfontIcon "";
          ramp-7 = nerdfontIcon "";
          ramp-0-foreground = "\${colors.ok}";
          ramp-1-foreground = "\${colors.ok}";
          ramp-2-foreground = "\${colors.ok}";
          ramp-3-foreground = "\${colors.warn}";
          ramp-4-foreground = "\${colors.warn}";
          ramp-5-foreground = "\${colors.warn}";
          ramp-6-foreground = "\${colors.warn}";
          ramp-7-foreground = "\${colors.alert}";
        })
        (mkModule "github" "internal/github" {
          token = mkIf (config.my.github.oauth-token != null) config.my.github.oauth-token;
          user = config.my.github.user;
        })
        {
          "module/dunst" = {
            type = "custom/script";
            exec =
              let
                dunst-module = pkgs.writeShellScriptBin "dunst-module" ''
                  IS_PAUSED=
                  declare -i COUNT_WAITING
                  declare -i COUNT_DISPLAYED
                  declare -i COUNT_HISTORY

                  function is_paused() {
                    IS_PAUSED=$(dunstctl is-paused)
                    [[ $IS_PAUSED == "true" ]] || return 1
                  }

                  function some_waiting() {
                    COUNT_WAITING=$(dunstctl count waiting)
                    (( COUNT_WAITING > 0 )) || return 1
                  }

                  function some_displayed() {
                    COUNT_DISPLAYED=$(dunstctl count displayed)
                    (( COUNT_DISPLAYED > 0 )) || return 1
                  }

                  function some_history() {
                    COUNT_HISTORY=$(dunstctl count history)
                    (( COUNT_HISTORY > 0 )) || return 1
                  }

                  while :; do
                    echo -n '%{A1:dunstctl set-paused toggle:}' # left click
                    echo -n '%{A2:dunstctl close-all:}'         # middle click
                    echo -n '%{A3:dunstctl context:}'           # right click
                    echo -n '%{A4:dunstctl close:}'             # scroll up
                    echo -n '%{A5:dunstctl history-pop:}'       # scroll down

                    if is_paused; then
                      tags="%{B$PAUSED_BG}%{F$PAUSED_FG}"
                      if some_waiting; then
                        text="${nerdfontIcon nerdfonts.md.bell_sleep} ($COUNT_WAITING)"
                      else
                        text="${nerdfontIcon nerdfonts.md.bell_sleep_outline}"
                      fi
                    else
                      tags="%{B$ACTIVE_BG}%{F$ACTIVE_FG}"
                      if some_displayed; then
                        text='${nerdfontIcon nerdfonts.md.bell_alert}'
                      else
                        text='${nerdfontIcon nerdfonts.md.bell}'
                      fi
                    fi

                    # need to manually pad with whitespace because background is changed dynamically
                    echo -n "$tags  $text  "

                    echo -n '%{A}'
                    echo -n '%{A}'
                    echo -n '%{A}'
                    echo -n '%{A}'
                    echo -n '%{A}'
                    echo

                    sleep 1
                  done
                '';
              in
              "${dunst-module}/bin/dunst-module";
            tail = true;
            env-ACTIVE_FG = "\${colors.foreground-dark}";
            env-ACTIVE_BG = "\${colors.background}";
            env-PAUSED_FG = "\${colors.background-alt}";
            env-PAUSED_BG = "\${colors.warn}";
          };
        }
        (
          let sep = {
            type = "custom/text";
            content = " ";
            content-foreground = "\${colors.transparent}";
            content-background = "\${colors.transparent}";
          };
          in
          {
            "module/sep1" = sep;
            "module/sep2" = sep;
            "module/sep3" = sep;
            "module/sep4" = sep;
            "module/sep5" = sep;
          }
        )
      ]
      ++
      (forEach cfg.networks
        ({ interface, interface-type, ... }@settings:
          (mkModule "network-${interface}" "internal/network" ({
            inherit interface;

            format-connected =
              if interface-type == "wireless"
              then "<ramp-signal>"
              else "<label-connected>";
            format-connected-padding = 2;
            format-connected-background = "\${colors.background}";
            format-connected-foreground = "\${colors.foreground-dark}";
            label-connected = nerdfontIcon nerdfonts.md.network_outline;

            format-disconnected = "<label-disconnected>";
            format-disconnected-padding = 2;
            format-disconnected-background = "\${colors.background}";
            format-disconnected-foreground = "\${colors.foreground-dark}";
            label-disconnected =
              if interface-type == "wireless"
              then (nerdfontIcon nerdfonts.md.wifi_off)
              else (nerdfontIcon nerdfonts.md.network_off);

            format-packetloss = "<animation-packetloss> <label-packetloss>";
            format-packetloss-padding = 2;
            format-packetloss-background = "\${colors.background}";
            format-packetloss-foreground = "\${colors.foreground-dark}";

            ramp-signal-0 = nerdfontIcon nerdfonts.md.wifi_strength_1;
            ramp-signal-1 = nerdfontIcon nerdfonts.md.wifi_strength_2;
            ramp-signal-2 = nerdfontIcon nerdfonts.md.wifi_strength_3;
            ramp-signal-3 = nerdfontIcon nerdfonts.md.wifi_strength_4;
          } // settings))))
      ++
      lib.singleton cfg.config);

    # extraConfig = ''
    #   ${let extraConfigDir = "${config.xdg.configHome}/polybar/config.d"; in
    #     lib.optionalString (lib.pathExists extraConfigDir)
    #       "include-directory = ${extraConfigDir}"}
    # '';

    # HACK: setup PATH for scripts
    systemd.user.services.polybar.Service.Environment =
      let path = lib.makeBinPath
        [
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
      lib.mkForce
        "PATH=${path}";

    systemd.user.services.polybar.Install.WantedBy = [ "graphical-session.target" ];

  };
}
