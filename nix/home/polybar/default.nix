{ config, lib, pkgs, ... }:

with builtins;
with lib;

let
  inherit (lib.my) nerdfonts;

  cfg = config.modules.polybar;

  ### fonts
  # NOTE: fonts are defined with 0-indexing, but referenced with 1-indexing
  # font-N = <fontconfig pattern>;<vertical offset>
  barFonts = [
    "JetBrainsMono Nerd Font:size=10;3" # T1
    "JetBrainsMono Nerd Font:size=10:style=Bold;3" # T2
    "Symbols Nerd Font:size=12;3" # T3
    "Symbols Nerd Font:size=16;3" # T4
    "Symbols Nerd Font:size=28;7" # T5 # (separators)
  ];

  ### colors
  baseColors = mapAttrs (k: v: "#${v}")
    (filterAttrs (k: _: hasPrefix "base" k) config.colorScheme.colors);

  colors = with config.colorScheme.colors;
    baseColors // {
      transparent = "#00000000";
      # see https://github.com/tinted-theming/home/blob/main/styling.md
      background = base00;
      background-alt = base01;
      foreground-dim = base03;
      foreground = base05;
      foreground-light = base06;
      highlight = base0A;
      selection = base02;
      primary = base0D;
      secondary = base0C;
      ok = base0B; # i.e. diff added
      warn = base0E; # i.e. diff changed
      alert = base08; # i.e. diff deleted
      magenta = base09;
    };

  ### helpers
  mkActionStr = { button ? null, command, text }:
    # 1: left click
    # 2: middle click
    # 3: right click
    # 4: scroll up
    # 5: scroll down
    # 6: double left click
    # 7: double middle click
    # 8: double right click
    assert isInt button;
    "%{A${toString button}:${escape [ ":" ] command}:}${text}%{A}";

  tag = {
    font = index: text: "%{T${toString (index + 1)}}${text}%{T-}";
    fg = color: text: "%{F${color}}${text}%{F-}"; # foreground
    bg = color: text: "%{B${color}}${text}%{B-}"; # background
    underline = color: text: "%{u${color}}${text}%{u-}"; # underline
    overline = color: text: "%{o${color}}${text}%{o-}"; # overline
    offset = gap: text: "%{O${toString gap}}${text}"; # offset
    reverse = text: "%{R}${text}";
    action = button: command: text:
      mkActionStr { inherit button command text; };
  };

  mkStyle = functions: text: pipe text functions;

  iconStyle =
    mkStyle [ (tag.offset (-1)) (tag.font 2) (tag.fg colors.foreground-dim) ];

  ### deprecated ###
  fontText = fontIndex: value:
    "%{T${toString (fontIndex + 1)}}${toString value}%{T-}";
  iconFont = 2; # see settings."bar/base".font
  iconText = fontText iconFont;
  iconLargeText = fontText 3; # see settings."bar/base".font
  #################

  withSeparator = sepModule: moduleNames:
    pipe moduleNames [
      (remove (name: name == null || name == "" || name == [ ]))
      (intersperse sepModule)
      flatten
    ];

  ### options
  modulesType = with lib.types;
    submodule {
      options = {
        left = mkOption {
          type = listOf str;
          default = [ ];
        };
        center = mkOption {
          type = listOf str;
          default = [ ];
        };
        right = mkOption {
          type = listOf str;
          default = [ ];
        };
      };
    };
  barType = with lib.types;
    submodule {
      options = {
        height = mkOption { type = int; };
        modules = mkOption { type = modulesType; };
        settings = mkOption {
          type = attrs;
          default = { };
        };
      };
    };
in {
  options.modules.polybar = {
    package = mkOption {
      type = types.package;
      default = pkgs.polybarFull;
    };
    bars = mkOption {
      type = types.attrsOf barType;
      default = {
        "top" = {
          height = 40;
          modules = {
            left = withSeparator "nerdfonts_ple_pixelated_squares_small" [
              (optionalString config.xsession.windowManager.i3.enable "i3")
              "xwindow"
            ];
            center = [ "time" "date" ];
            right = withSeparator "nerdfonts_ple_backslash_separator" [
              "gh"
              # "kubernetes"
              (optionalString config.services.dunst.enable "dunst")
              (optionalString config.my.deadd.enable "deadd")
              "pulseaudio"
              "memory"
              "gpu"
              "cpu"
              "temperature"
              (forEach cfg.networks
                ({ interface, ... }: "network-${interface}"))
              "powermenu"
            ];
          };
        };
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
    colors = mkOption {
      type = types.attrs;
      default = { };
    };
    settings = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = {

    xdg.configFile."polybar/config.ini".onChange =
      mkIf config.services.polybar.enable ''
        ${pkgs.procps}/bin/pkill -u "$USER" ''${VERBOSE+-e} polybar || true
      '';

    services.polybar = {
      package = cfg.package;
      settings = foldl' recursiveUpdate { } [
        (nvs "colors" colors)
        (nvs "settings" {
          # Compositing operators
          # @see: https://www.cairographics.org/manual/cairo-cairo-t.html#cairo-operator-t
          compositing.background = "source";
          compositing.foreground = "over";
          compositing.overline = "over";
          compositing.underline = "over";
          compositing.border = "over";
          pseudo-transparency = !config.services.picom.enable;
        })
        (nvs "bar/base" {
          font = barFonts;
          background = "\${colors.transparent}";
          foreground = "\${colors.foreground}";
          line.size = 3;
          line.color = "\${colors.primary}";
          border.color = "\${colors.transparent}";
          border.bottom.size = 0;
          border.top.size = 1;
          border.left.size = 5;
          border.right.size = 5;
          spacing = 0;
          padding = 0;
          separator = "";
          # Reload when the screen configuration changes (XCB_RANDR_SCREEN_CHANGE_NOTIFY event)
          screenchange-reload = true;
          enable-ipc = true; # enable communication with polybar-msg
        })
        (nvs "bar/top" {
          "inherit" = "bar/base";
          monitor.text = "\${env:MONITOR:DP-0}"; # set by script
          monitor.fallback = "";
          monitor.strict = false;
          modules.left = concatStringsSep " " cfg.bars.top.modules.left;
          modules.center = concatStringsSep " " cfg.bars.top.modules.center;
          modules.right = concatStringsSep " " cfg.bars.top.modules.right;
          bottom = false;
          width = "100%";
          height = cfg.bars.top.height;
          fixed-center = true;
          module.margin.left = 0;
          module.margin.right = 0;
          tray.background = "\${colors.background}";
          tray.position = "right";
          tray.maxsize = 18;
          tray.padding = 2;
          tray.scale = "1.0";
          tray.offset-x = 0;
          tray.offset-y = 0;
          tray.detached = false;
          tray.margin.left = 3;
          cursor.click = "pointer"; # hand
          cursor.scroll = "ns-resize"; # arrows
        })
        ####################################################
        (nvs "module/base" {
          background = "\${colors.background}";
          foreground = "\${colors.foreground}";
          format = {
            background = "\${colors.background}";
            foreground = "\${colors.foreground}";
            prefix.foreground = "\${colors.foreground-dim}";
            suffix.foreground = "\${colors.foreground-dim}";
          };
          label.margin = 1;
        })
        (nvs "module/base-alt" {
          background = "\${colors.background-alt}";
          foreground = "\${colors.foreground-light}";
          format = {
            background = "\${colors.background-alt}";
            foreground = "\${colors.foreground-light}";
            prefix.foreground = "\${colors.foreground}";
            suffix.foreground = "\${colors.foreground}";
          };
          label.margin = 1;
        })
        ####################################################
        (nvs "module/date" {
          "inherit" = "module/base-alt";
          type = "internal/date";
          interval = 60;
          date.text = "%x";
          date.alt = "%A, %B %0e";
          label.text = "%date%";
          format.text = "${iconStyle nerdfonts.md.calendar} <label>";
          format.padding = 2;
          padding = 2;
        })
        (nvs "module/time" {
          "inherit" = "module/base";
          type = "internal/date";
          interval = 1;
          time.text = "%r";
          time.alt = "%F-%T%z";
          format.text = "${iconStyle nerdfonts.md.clock} <label>";
          label.text = "%time%";
          format.padding = 2;
          format.margin = 0;
        })
        ####################################################
        (nvs "module/pulseaudio" {
          "inherit" = "module/base";
          type = "internal/pulseaudio";
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
              foreground = "\${colors.foreground-dim}";
            };
          };
          click.right = "${pkgs.pavucontrol}/bin/pavucontrol &";
          use-ui-max = false; # uses PA_VOLUME_NORM (maxes at 100%)
        })
        ####################################################
        (nvs "module/xwindow" {
          "inherit" = "module/base";
          type = "internal/xwindow";
          format.text = "${iconStyle nerdfonts.md.dock_window} <label>";
          format.padding = 2;
          label = {
            text = "%title%";
            maxlen = 64;
            empty = {
              text = "Empty";
              foreground = "\${colors.foreground-dim}";
            };
          };
          click.left =
            "${config.programs.rofi.finalPackage}/bin/rofi -show window -monitor -3"; # -3 means launch at position of mouse
        })
        ####################################################
        (nvs "module/i3" {
          "inherit" = "module/base";
          type = "internal/i3";
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
              foreground = "\${colors.foreground-dim}";
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
          show-urgent =
            true; # Show urgent workspaces regardless of whether the workspace is hidden by pin-workspaces.
          strip-wsnumbers = true; # Split the workspace name on ':'
          fuzzy-match =
            true; # Use fuzzy (partial) matching on labels when assigning icons to workspaces
        })
        ####################################################
        (nvs "module/gh" {
          "inherit" = "module/base";
          type = "custom/script";
          interval = 60;
          # exec-if = "gh auth status";
          label.text = "%output%";
          label-fail = "${iconText nerdfonts.seti.error} ${
              iconText nerdfonts.oct.mark_github
            } %output%";
          format.text = "<label>";
          exec = let
            alertStyle = mkStyle [
              (tag.bg colors.base0E)
              (tag.fg colors.base00)
              (tag.font 2)
            ];
          in pkgs.writeShellScript "github" ''
            export PATH=${
              makeBinPath [
                config.programs.gh.package
                config.programs.jq.package
                config.programs.rofi.finalPackage
                pkgs.xdg-utils
                pkgs.moreutils
              ]
            }:$PATH

            get_pr_awaiting_review() {
              gh api \
                -X GET search/issues \
                -f q='type:pr state:open draft:false user-review-requested:@me -reviewed-by:@me -org:optimizely'
            }

            display_prs() {
              local data=$(get_pr_awaiting_review)
              local count=$(jq -r .total_count <<<"$data")

               case $count in
                  0)
                    echo -e "${
                      tag.action 1
                      "xdg-open https://github.com/pulls/review-requested"
                      (iconStyle " ${nerdfonts.oct.git_pull_request} $count ")
                    }"
                      ;;
                  *)
                  echo -e "${
                    tag.action 1
                    "xdg-open https://github.com/pulls/review-requested"
                    (alertStyle " ${nerdfonts.oct.git_pull_request} $count ")
                  }"
                  ;;
               esac

              # case $count in
                 # 0) ;;
                 # *) echo -en "%{A:xdg-open "$(jq -r '.items[0].html_url | @uri' <<<"$data")":} $(pr_icon) 1 %{A}" ;;
                 # *) echo -en "%{A:jq -r '.items[].html_url | @uri' <<<"$data" | rofi -dmenu | ifne xargs xdg-open } $(pr_icon) $count %{A}" ;;
              # esac
            }

            display_full() {
              display_prs
            }

            display_full
          '';
        })
        ####################################################
        (nvs "module/memory" {
          "inherit" = "module/base";
          type = "internal/memory";
          interval = 2;
          format = {
            prefix = "RAM";
            text = "<label> <bar-used>";
          };
          label.text = "%percentage_used%%";
          label.margin = 1;
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
        })
        ####################################################
        (nvs "module/gpu" {
          "inherit" = "module/base";
          type = "custom/script";
          interval = 5;
          format.prefix = "GPU";
          label.margin = 1;
        })
        ####################################################
        (nvs "module/cpu" {
          "inherit" = "module/base";
          type = "internal/cpu";
          interval = 2;
          format = {
            prefix = "CPU";
            text = "<label> <bar-coreload>";
          };
          label.text = "%percentage%%";
          label.margin = 1;
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
            {
              text = "▁";
              foreground = "\${colors.ok}";
              spacing = 0;
            }
            {
              text = "▂";
              foreground = "\${colors.ok}";
              spacing = 0;
            }
            {
              text = "▃";
              foreground = "\${colors.ok}";
              spacing = 0;
            }
            {
              text = "▄";
              foreground = "\${colors.warn}";
              spacing = 0;
            }
            {
              text = "▅";
              foreground = "\${colors.warn}";
              spacing = 0;
            }
            {
              text = "▆";
              foreground = "\${colors.warn}";
              spacing = 0;
            }
            {
              text = "▇";
              foreground = "\${colors.warn}";
              spacing = 0;
            }
            {
              text = "█";
              foreground = "\${colors.alert}";
              spacing = 0;
            }
          ];
        })
        ####################################################
        (nvs "module/temperature" {
          "inherit" = "module/base";
          type = "internal/temperature";
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
          label.text = "%temperature-c%";
          label.warn = "%temperature-c%";
          label.margin = 1;
          units = true;
          ramp = [
            {
              margin = 1;
              text = iconText "";
              foreground = "\${colors.ok}";
            }
            {
              margin = 1;
              text = iconText "";
              foreground = "\${colors.ok}";
            }
            {
              margin = 1;
              text = iconText "";
              foreground = "\${colors.ok}";
            }
            {
              margin = 1;
              text = iconText "";
              foreground = "\${colors.warn}";
            }
            {
              margin = 1;
              text = iconText "";
              foreground = "\${colors.warn}";
            }
            {
              margin = 1;
              text = iconText "";
              foreground = "\${colors.warn}";
            }
            {
              margin = 1;
              text = iconText "";
              foreground = "\${colors.warn}";
            }
            {
              margin = 1;
              text = iconText "";
              foreground = "\${colors.alert}";
            }
          ];
        })
        ####################################################
        (nvs "module/dunst" {
          type = "custom/script";
          exec-if = "dunstctl debug";
          exec = "${./scripts/polybar-dunst.sh}";
          tail = true;
          env = {
            ACTIVE_FG = "\${colors.foreground-dim}";
            ACTIVE_BG = "\${colors.background}";
            PAUSED_FG = "\${colors.background-alt}";
            PAUSED_BG = "\${colors.warn}";
            ICON_FONT = "3";
            INTERVAL = 1;
          };
        })
        ####################################################
        (let
          kubebar = pkgs.writeShellApplication {
            name = "kubebar";
            runtimeInputs = with pkgs; [ kubectl entr jq envsubst ];
            text = builtins.readFile ./kubebar.bash;
          };
        in nvs "module/kubernetes" {
          type = "custom/script";
          exec-if = "kubectl version --client=true";
          # tail = true;
          # exec = "${kubebar}/bin/kubebar --watch";
          exec = "${kubebar}/bin/kubebar --no-watch";
          env = {
            KUBEBAR_ESCAPE = "@";
            KUBEBAR_FORMAT = concatStrings [
              "%{A1:kitty-floating k9s &:}"
              "%{F#${config.colorScheme.colors.base04}}${
                iconText nerdfonts.md.kubernetes
              }%{F-} "
              "@{KUBE_CURRENT_CONTEXT}/@{KUBE_CURRENT_NAMESPACE}"
              "%{A}"
            ];
          };
          tail = false;
          interval = 10;
          background = "\${colors.background}";
          foreground = "\${colors.foreground}";
          format.background = "\${colors.background}";
          format.foreground = "\${colors.foreground}";
          format.prefix-foreground = "\${colors.foreground-dim}";
          format.suffix-foreground = "\${colors.foreground-dim}";
          format.prefix-padding = 1;
          format.padding = 2;
        })
        ####################################################
        (let
          toggleScript = pkgs.writeShellScript "deadd-toggle" ''
            kill -s USR1 $(pidof deadd-notification-center)
          '';
        in nvs "module/deadd" {
          type = "custom/text";
          content.text = tag.action 1 "${toggleScript}" (iconStyle " ${nerdfonts.oct.bell} ");
          content.foreground = "\${colors.foreground}";
          content.background = "\${colors.background}";
        })
        ####################################################
        (nvs "module/powermenu" {
          type = "custom/menu";
          hidden = true;
          menu-0-0 = "poweroff";
          menu-0-0-exec = "poweroff";
          menu-0-1 = "Suspend";
          menu-0-1-exec = "systemctl suspend";
          menu-0-2 = "Lock";
          menu-0-2-exec = "xautolock -locknow";
        })
        ## Separators ######################################
        (nvs "module/space" {
          type = "custom/text";
          content = {
            text = " ";
            padding = 0;
            foreground = "\${colors.transparent}";
            background = "\${colors.transparent}"; # "\${colors.alert}"
            font = 5;
          };
        })
        (nvs "module/nerdfonts_ple" {
          content.foreground = "\${colors.background-alt}";
          content.background = "\${colors.background}";
          content.font = 5; # T5
          content.offset = (-5);
        })
        (nvs "module/nerdfonts_ple-alt" {
          content.foreground = "\${colors.background}";
          content.background = "\${colors.background-alt}";
          content.font = 5; # T5
          content.offset = (-5);
        })
        (mapAttrs' (name: text:
          (nameValuePair "module/nerdfonts_ple_${name}" {
            type = "custom/text";
            "inherit" = "module/nerdfonts_ple";
            content.text = text;
          })) nerdfonts.ple)
        (mapAttrs' (name: text:
          (nameValuePair "module/nerdfonts_ple_${name}-alt" {
            type = "custom/text";
            "inherit" = "module/nerdfonts_ple-alt";
            content.text = text;
          })) nerdfonts.ple)
        cfg.settings
      ];

      #####################################################
      # TODO finish converting to services.polybar.settings
      config = let
        mkModule = name: type: settings: {
          "module/${name}" = {
            inherit type;
            background = "\${colors.background}";
            foreground = "\${colors.foreground}";
            format-background = "\${colors.background}";
            format-foreground = "\${colors.foreground}";
            format-prefix-foreground = "\${colors.foreground-dim}";
            format-suffix-foreground = "\${colors.foreground-dim}";
            format-prefix-padding = 1;
            format-padding = 2;
          } // settings;
        };
      in fold recursiveUpdate { } (forEach cfg.networks
        ({ interface, interface-type, ... }@settings:
          (mkModule "network-${interface}" "internal/network" ({
            inherit interface;

            format-connected = if interface-type == "wireless" then
              "<ramp-signal>"
            else
              "<label-connected>";
            format-connected-padding = 2;
            format-connected-background = "\${colors.background}";
            format-connected-foreground = "\${colors.foreground-dim}";
            label-connected = "%{A1:nm-connection-editor &:}${
                iconText nerdfonts.md.network_outline
              }%{A}";

            format-disconnected = "<label-disconnected>";
            format-disconnected-padding = 2;
            format-disconnected-background = "\${colors.background}";
            format-disconnected-foreground = "\${colors.foreground-dim}";
            label-disconnected = if interface-type == "wireless" then
              (iconText nerdfonts.md.wifi_off)
            else
              (iconText nerdfonts.md.network_off);

            format-packetloss = "<animation-packetloss> <label-packetloss>";
            format-packetloss-padding = 2;
            format-packetloss-background = "\${colors.background}";
            format-packetloss-foreground = "\${colors.foreground-dim}";

            ramp-signal-0 = iconText nerdfonts.md.wifi_strength_1;
            ramp-signal-1 = iconText nerdfonts.md.wifi_strength_2;
            ramp-signal-2 = iconText nerdfonts.md.wifi_strength_3;
            ramp-signal-3 = iconText nerdfonts.md.wifi_strength_4;
          } // settings))));

      extraConfig = ''
        include-directory = ${config.xdg.configHome}/polybar/polybar.d
      '';

      script = let
        bars = [ "top" ]; # TODO use from cfg
        cmds = forEach bars (bar: "polybar ${bar} &");
      in ''
        for m in $(polybar --list-monitors | cut -d: -f1); do
          MONITOR=$m ${concatStringsSep "\n" cmds}
        done
      '';
    };

    # HACK: setup PATH for scripts
    systemd.user.services.polybar.Service.Environment = mkForce "PATH=${
        makeBinPath [
          cfg.package
          "/run/current-system/sw"
          "${config.home.homeDirectory}/.nix-profile"
          "${config.home.homeDirectory}/.dotfiles"
          "${config.home.homeDirectory}/.dotfiles/local"
        ]
      }";
    systemd.user.services.polybar.Install.WantedBy =
      [ "graphical-session.target" ];
    systemd.user.services.polybar.Unit.After = [ "graphical-session.target" ];
  };
}
