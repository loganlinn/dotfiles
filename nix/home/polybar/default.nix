{ config, lib, pkgs, nerdfonts, ... }:

with builtins;
with lib;

let
  cfg = config.modules.polybar;

  # helpers
  fontText = fontIndex: value: "%{T${toString (fontIndex + 1)}}${toString value}%{T-}";
  iconText = fontText 2; # see settings."bar/base".font
  iconLargeText = fontText 3; # see settings."bar/base".font
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
    package = mkOption {
      type = types.package;
      default = pkgs.polybarFull;
    };

    # TODO convert to submodule
    bars.top = {
      height = mkOption {
        type = types.number;
        default = 40;
      };

      modules-left = mkOption {
        type = with types; listOf str;
        default = [ "date" "xwindow" ];
      };

      modules-center = mkOption {
        type = with types; listOf str;
        default = optionals config.xsession.windowManager.i3.enable [ "i3" ];
      };

      modules-right = mkOption {
        type = with types; listOf str;
        default = [
          "memory"
          "gpu"
          "cpu"
          "temperature"
          "sep4"
          "pulseaudio"
          "sep3"
        ]
        ++ optional config.services.dunst.enable "dunst"
        ++ (forEach cfg.networks ({ interface, ... }: "network-${interface}"))
        ++ [
          "sep1"
          "date"
        ];
      };
    };
    networks = mkOption {
      type = with types; listOf attrs;
      default = [ ];
    };
    config = mkOption {
      type = types.attrs;
      default = { };
    };
    settings = mkOption {
      type = types.attrs;
      default = { };
    };
    colors = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = {
    services.polybar = {
      package = cfg.package;

      settings =
        let
          section = parents: attrs: { "inherit" = concatStringsSep " " (toList parents); } // attrs;
          module = type: attrs: (section "module/base" { inherit type; } // attrs);
        in
        recursiveUpdate
          {
            settings = {
              # Compositing operators
              # @see: https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-operator-t
              compositing = {
                background = "source";
                foreground = "over";
                overline = "over";
                underline = "over";
                border = "over";
              };

              pseudo-transparency = !config.services.picom.enable;
            };

            colors =
              let
                baseColors = mapAttrs (k: v: "#${v}") (filterAttrs (k: _: hasPrefix "base" k) config.colorScheme.colors);
                alias = name: "\${colors.${name}}";
              in
              baseColors // (with config.colorScheme.colors;
              {
                transparent = "#00000000";
                # see https://github.com/tinted-theming/home/blob/main/styling.md
                background = base00;
                background-alt = base01;
                background-highlight = base03;
                foreground-dark = base04;
                foreground = base05;
                foreground-light = base06;
                highlight = base0A;
                selection = base02;
                primary = base0D;
                secondary = base0C;
                ok = base0B; # i.e. diff added
                warn = base0E; # i.e. diff changed
                alert = base08; # i.e. diff deleted
              });

            "bar/base" = {
              background = "\${colors.transparent}";
              foreground = "\${colors.foreground}";

              # NOTE: fonts are defined with 0-indexing, but referenced with 1-indexing
              # font-N = <fontconfig pattern>;<vertical offset>
              font = [
                "JetBrainsMono Nerd Font:size=10;3"
                "JetBrainsMono Nerd Font:size=10:style=Bold;3"
                "Symbols Nerd Font:size=12;3"
                "Symbols Nerd Font:size=16;3"
              ];

              line.size = 3;
              line.color = "\${colors.primary}";

              border = {
                color = "\${colors.transparent}";
                bottom.size = 0;
                top.size = 4;
                left.size = 5;
                right.size = 5;
              };

              spacing = 0;
              padding = 0;

              separator = "";

              # Reload when the screen configuration changes (XCB_RANDR_SCREEN_CHANGE_NOTIFY event)
              screenchange-reload = true;

              enable-ipc = true; # enable communication with polybar-msg
            };

            "bar/top" = {
              "inherit" = "bar/base";

              monitor.text = "\${env:MONITOR:DP-0}"; # set by script
              monitor.fallback = "";
              monitor.strict = false;

              modules.left = concatStringsSep " " cfg.bars.top.modules-left;
              modules.center = concatStringsSep " " cfg.bars.top.modules-center;
              modules.right = concatStringsSep " " cfg.bars.top.modules-right;

              bottom = false;
              width = "100%";
              height = cfg.bars.top.height;
              offset.x = "0%";
              offset.y = "0%";
              fixed-center = true;

              module.margin.left = 0;
              module.margin.right = 0;

              tray = {
                background = "\${colors.background}";
                position = "right";
                maxsize = 18;
                padding = 2;
                scale = "1.0";
                offset-x = 0;
                offset-y = 0;
                detached = false;
              };

              cursor = {
                click = "pointer"; # hand
                scroll = "ns-resize"; # arrows
              };
            };

            "module/base" = {
              background = "\${colors.background}";
              foreground = "\${colors.foreground}";
              format = {
                background = "\${colors.background}";
                foreground = "\${colors.foreground}";
                prefix.foreground = "\${colors.foreground-dark}";
                suffix.foreground = "\${colors.foreground-dark}";
                prefix.padding = 1;
                padding = 2;
              };
            };

            "module/date" = module "internal/date" {
              interval = 1;
              time.text = "%I:%M %p";
              date.text = "%a %b %d";
              time.alt = "%l:%M:%S";
              date.alt = " ";
              format.text = "<label>";
              format.prefix = nerdfonts.md.calendar_clock;
              label = "%date% %time%";
            };

            "module/pulseaudio" = module "internal/pulseaudio" {
              interval = 5;
              label = {
                volume = "%percentage%%";
                muted = " MUTED";
              };
              format = {
                volume = {
                  text = "<ramp-volume> <label-volume>";
                  background = "\${colors.background}";
                  foreground = "\${colors.foreground}";
                  padding = 2;
                };
                muted = {
                  text = "<label-muted>";
                  prefix = iconText nerdfonts.md.volume_off;
                  prefix-foreground = "\${colors.background}";
                  background = "\${colors.warn}";
                  foreground = "\${colors.background}";
                  padding = 2;
                };
              };
              ramp = {
                volume = {
                  text = map iconLargeText [
                    nerdfonts.md.volume_low
                    nerdfonts.md.volume_medium
                    nerdfonts.md.volume_high
                  ];
                  weight = 2;
                  foreground = "\${colors.foreground-dark}";
                };
              };
              click.right = "${pkgs.pavucontrol}/bin/pavucontrol &";
              use-ui-max = false; # uses PA_VOLUME_NORM (maxes at 100%)
            };

            # "module/pulseaudio_source" = module "custom/script" {
            # };

            "module/xwindow" = module "internal/xwindow" {
              format = {
                prefix = nerdfonts.md.dock_window;
                text = "<label>";
              };
              label = {
                text = "%title%";
                maxlen = 64;
                empty = {
                  text = "Empty";
                  foreground = "\${colors.foreground-dark}";
                };
              };
              click.left = "${config.programs.rofi.finalPackage}/bin/rofi -show window -monitor -3"; # -3 means launch at position of mouse
            };

            "module/i3" = module "internal/i3" {
              format = {
                text = "<label-state> <label-mode>";
                padding = 0;
              };
              label = {
                focused = {
                  text = "%name%";
                  background = "\${colors.background-alt}";
                  foreground = "\${colors.foreground-light}";
                  underline = "\${colors.highlight}";
                  padding = 2;
                };
                mode = {
                  text = "%mode%";
                  background = "\${colors.warn}";
                  foreground = "\${colors.background}";
                  padding = 2;
                };
                unfocused = {
                  text = "%name%";
                  background = "\${colors.background}";
                  foreground = "\${colors.foreground-dark}";
                  padding = 2;
                };
                urgent = {
                  text = "%name%";
                  background = "\${colors.alert}";
                  foreground = "\${colors.background}";
                  padding = 2;
                };
                visible = {
                  text = "%name%";
                  background = "\${colors.background}";
                  foreground = "\${colors.foreground}";
                  underline = "\${colors.foreground}";
                  padding = 2;
                };
              };
              enable = {
                click = true;
                scroll = false;
              };
              index-sort = true; # Sort the workspaces by index instead by output
              pin-workspaces = false; # only show workspaces on the current monitor
              show-urgent = true; # Show urgent workspaces regardless of whether the workspace is hidden by pin-workspaces.
              strip-wsnumbers = true; # Split the workspace name on ':'
              fuzzy-match = true; # Use fuzzy (partial) matching on labels when assigning icons to workspaces
            };

            "module/memory" = module "internal/memory" {
              interval = 2;
              format = {
                prefix = "RAM";
                text = "<label> <bar-used>";
              };
              label.text = "%percentage_used%%";
              bar.used = {
                width = 6;
                foreground = [
                  "\${colors.ok}"
                  "\${colors.ok}"
                  "\${colors.ok}"
                  "\${colors.warn}"
                  "\${colors.warn}"
                  "\${colors.alert}"
                ];
                indicator.text = "|";
                indicator.foreground = "#ff";
                fill.text = "┅";
                empty.text = "┅";
                empty.foreground = "\${colors.base04}";
              };
            };

            "module/gpu" = module "custom/script" {
              interval = 5;
              format.prefix = "GPU";
            };

            "module/cpu" = module "internal/cpu" {
              interval = 2;
              format = {
                prefix = "CPU";
                text = "<label> <bar-coreload>";
              };
              label = {
                text = "%percentage%%";
              };
              bar.coreload = {
                width = 6;
                foreground = [
                  "\${colors.ok}"
                  "\${colors.ok}"
                  "\${colors.ok}"
                  "\${colors.warn}"
                  "\${colors.warn}"
                  "\${colors.alert}"
                ];
                indicator.text = "|";
                indicator.foreground = "#ff";
                fill.text = "┅";
                empty.text = "┅";
                empty.foreground = "\${colors.base04}";
              };
              ramp.coreload = [
                { text = "▁"; foreground = "\${colors.ok}"; spacing = 0; }
                { text = "▂"; foreground = "\${colors.ok}"; spacing = 0; }
                { text = "▃"; foreground = "\${colors.ok}"; spacing = 0; }
                { text = "▄"; foreground = "\${colors.warn}"; spacing = 0; }
                { text = "▅"; foreground = "\${colors.warn}"; spacing = 0; }
                { text = "▆"; foreground = "\${colors.warn}"; spacing = 0; }
                { text = "▇"; foreground = "\${colors.warn}"; spacing = 0; }
                { text = "█"; foreground = "\${colors.alert}"; spacing = 0; }
              ];
            };

            "module/temperature" = module "internal/temperature" {
              interval = 3;
              format = {
                prefix = "TEMP";
                text = "<label> <ramp>";
                warn = {
                  text = "<label-warn> <ramp>";
                  background = "\${colors.base00}";
                  foreground = "\${colors.foreground}";
                  padding = 2;
                };
              };
              label = {
                text = "%temperature-c%";
                warn = "%temperature-c%";
              };
              units = true;
              ramp = [
                { text = iconText ""; foreground = "\${colors.ok}"; }
                { text = iconText ""; foreground = "\${colors.ok}"; }
                { text = iconText ""; foreground = "\${colors.ok}"; }
                { text = iconText ""; foreground = "\${colors.warn}"; }
                { text = iconText ""; foreground = "\${colors.warn}"; }
                { text = iconText ""; foreground = "\${colors.warn}"; }
                { text = iconText ""; foreground = "\${colors.warn}"; }
                { text = iconText ""; foreground = "\${colors.alert}"; }
              ];
            };

            "module/dunst" = {
              type = "custom/script";
              exec-if = "dunstctl debug";
              exec = "${./bin/polybar-dunst.sh}";
              tail = true;
              env = {
                ACTIVE_FG = "\${colors.foreground-dark}";
                ACTIVE_BG = "\${colors.background}";
                PAUSED_FG = "\${colors.background-alt}";
                PAUSED_BG = "\${colors.warn}";
                ICON_FONT = "3";
                INTERVAL = 1;
              };
            };

            # TODO reuse separator module?
            "module/sep1" = {
              type = "custom/text";
              content = {
                text = " ";
                foreground = "\${colors.transparent}";
                background = "\${colors.transparent}";
              };
            };
            "module/sep2" = {
              type = "custom/text";
              content = {
                text = " ";
                foreground = "\${colors.transparent}";
                background = "\${colors.transparent}";
              };
            };
            "module/sep3" = {
              type = "custom/text";
              content = {
                text = " ";
                foreground = "\${colors.transparent}";
                background = "\${colors.transparent}";
              };
            };
            "module/sep4" = {
              type = "custom/text";
              content = {
                text = " ";
                foreground = "\${colors.transparent}";
                background = "\${colors.transparent}";
              };
            };
          }
          cfg.settings;

      # TODO finish converting to services.polybar.settings
      config = fold recursiveUpdate { } (forEach cfg.networks ({ interface, interface-type, ... }@settings:
        (mkModule "network-${interface}" "internal/network" ({
          inherit interface;

          format-connected =
            if interface-type == "wireless"
            then "<ramp-signal>"
            else "<label-connected>";
          format-connected-padding = 2;
          format-connected-background = "\${colors.background}";
          format-connected-foreground = "\${colors.foreground-dark}";
          label-connected =
            "%{A1:nm-connection-editor &:}${iconText nerdfonts.md.network_outline}%{A}";

          format-disconnected = "<label-disconnected>";
          format-disconnected-padding = 2;
          format-disconnected-background = "\${colors.background}";
          format-disconnected-foreground = "\${colors.foreground-dark}";
          label-disconnected =
            if interface-type == "wireless"
            then (iconText nerdfonts.md.wifi_off)
            else (iconText nerdfonts.md.network_off);

          format-packetloss = "<animation-packetloss> <label-packetloss>";
          format-packetloss-padding = 2;
          format-packetloss-background = "\${colors.background}";
          format-packetloss-foreground = "\${colors.foreground-dark}";

          ramp-signal-0 = iconText nerdfonts.md.wifi_strength_1;
          ramp-signal-1 = iconText nerdfonts.md.wifi_strength_2;
          ramp-signal-2 = iconText nerdfonts.md.wifi_strength_3;
          ramp-signal-3 = iconText nerdfonts.md.wifi_strength_4;
        } // settings))));

      # extraConfig = ''
      #   ${let extraConfigDir = "${config.xdg.configHome}/polybar/config.d"; in
      #     optionalString (pathExists extraConfigDir)
      #       "include-directory = ${extraConfigDir}"}
      # '';

      script =
        let
          bars = [ "top" ]; # TODO use from cfg
          cmds = forEach bars (bar: "polybar ${bar} &");
        in
        ''
          for m in $(polybar --list-monitors | cut -d: -f1); do
            MONITOR=$m ${concatStringsSep "\n" cmds}
          done
        '';

    };

    # HACK: setup PATH for scripts
    systemd.user.services.polybar.Service.Environment = mkForce ''PATH=${makeBinPath [
      cfg.package
      "/run/current-system/sw"
      "${config.home.homeDirectory}/.nix-profile"
      "${config.home.homeDirectory}/.dotfiles"
      "${config.home.homeDirectory}/.dotfiles/local"
    ]}'';
    systemd.user.services.polybar.Install.WantedBy = [ "graphical-session.target" ];
    systemd.user.services.polybar.Unit.After = [ "graphical-session.target" ];
  };
}
