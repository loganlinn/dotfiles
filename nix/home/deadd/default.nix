{ config, lib, pkgs, ... }:

with lib;

let

  yamlFormat = pkgs.formats.yaml { };

  cfg = config.my.deadd;

  notify-send-py = (import ../../pkgs pkgs).notify-send-py;

  helpers = mapAttrs (name: text:
    pkgs.writeShellApplication {
      name = "deadd-${name}";
      runtimeInputs = with pkgs; [ procps findutils notify-send-py ];
      text = text;
    }) {
      toggle = ''
        if PID=$(pidof deadd-notification-center); then
          kill -s USR1 "$PID"
        fi
      '';
      highlighting-on = ''
        notify-send.py a --hint boolean:deadd-notification-center:true int:id:0 boolean:state:true type:string:buttons
      '';
      highlighting-off = ''
        notify-send.py a --hint boolean:deadd-notification-center:true int:id:0 boolean:state:false type:string:buttons
      '';
      center-clear = ''
        notify-send.py a --hint boolean:deadd-notification-center:true string:type:clearInCenter
      '';
      popups-clear = ''
        notify-send.py a --hint boolean:deadd-notification-center:true string:type:clearPopups
      '';
      popups-pause = ''
        notify-send.py a --hint boolean:deadd-notification-center:true string:type:pausePopups
      '';
      popups-unpause = ''
        notify-send.py a --hint boolean:deadd-notification-center:true string:type:unpausePopups
      '';
      style-reload = ''
        notify-send.py a --hint boolean:deadd-notification-center:true string:type:reloadStyle
      '';
      demo = ''
         set -x

         # Send notifications that only show up in the notification center but do not produce a popup:
         notify-send.py "Does not pop up" -t 1 &

         # Action buttons with gtk icons
         notify-send.py "And buttons" "Do you like buttons?" \
                        --hint boolean:action-icons:true \
                        --action yes:face-cool no:face-sick &

         # Notification images by gtk icon
         notify-send.py "GTK icon" "face-cool" --hint string:image-path:face-cool &

         # Notification images by file
         if image=$(find "$HOME" -name '*.png' -print -quit); then
           notify-send.py "Images path" "$(basename image)" --hint string:image-path:"file:/$image" &
         fi

         # Notification with progress bar
         notify-send.py "This notification has a progressbar" "33%" --hint "int:has-percentage:33)" &
         # OR notify-send.py "This notification has a progressbar" "33%" --hint "int:value:33)"

         # Notification with slider
         notify-send.py "This notification has a slider" "33%" \
                                  --hint int:has-percentage:33 \
                                  --action "changeValue:abc)" &

        wait < <(jobs -p)
      '';
    };

in {
  options.my.deadd = {
    enable = mkEnableOption "deadd-notification-center";
    package = mkPackageOption pkgs "deadd-notification-center" { };
    font = mkOption {
      type = lib.hm.types.fontType;
      default = config.my.fonts.terminal;
    };
    extraCSS = mkOption {
      type = types.str;
      default = "";
    };
    scripts = mkOption {
      type = with types; attrsOf (either str package);
      default = helpers;
    };
    settings = mkOption {
      type = yamlFormat.type;
      default = {
        notification-center = {
          monitor = 0;
          follow-mouse = false;
          hide-on-mouse-leave = true;
          new-first = true;
          ignore-transient = false;
          width = 512;
          margin-top = 48;
          margin-right = 0;
          margin-bottom = 0;
          buttons = {
            # buttons-per-row = 4;
            # button-height = 60;
            # button-margin = 2;
            actions = [
              # {
              #   label = "VPN";
              #   command = "sudo vpnToggle";
              # }
              # {
              #   label = "Bluetooth";
              #   command = "bluetoothToggle";
              # }
              # {
              #   label = "Wifi";
              #   command = "wifiToggle";
              # }
              # {
              #   label = "Screensaver";
              #   command = "screensaverToggle";
              # }
              # {
              #   label = "Keyboard";
              #   command = "keyboardToggle";
              # }
            ];
          };
        };

        notification = {
          use-markup = true;
          parse-html-entities = true;
          use-action-icons = true;

          # If noti-closed messages are enabled, the sending application
          # will know that a notification was closed/timed out. This can
          # be an issue for certain applications, that overwrite
          # notifications on status updates (e.g. Spotify on each
          # song). When one of these applications thinks, the notification
          # has been closed/timed out, they will not overwrite existing
          # notifications but send new ones. This can lead to redundant
          # notifications in the notification center, as the close-message
          # is send regardless of the notification being persisted.
          dbus.send-noti-closed = false;

          app-icon = {
            guess-icon-from-name = true;
            icon-size = 24;
          };

          image = {
            size = 48;
            margin-top = 14;
            margin-bottom = 14;
            margin-left = 14;
            margin-right = 0;
          };

          modifications = [
            # {
            #   match = { app-name = "Spotify"; };
            #   modify = {
            #     image-size = 80;
            #     timeout = 1;
            #     send-noti-closed = true;
            #     class-name = "Spotify";
            #   };
            # }
          ];

          popup = {
            default-timeout = 10000;
            width = 480;
            margin-top = 48;
            margin-right = 24;
            margin-between = 6;
            max-lines-in-body = 3;
            # Determines whether the GTK widget that displays the notification body
            # in the notification popup will be hidden when empty. This is especially
            # useful for transient notifications that display a progress bar.
            hide-body-if-empty = true;
            click-behavior = {
              dismiss = "mouse3";
              default-action = "mouse1";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ] ++ (attrValues helpers);

    xdg.configFile."deadd/deadd.yml".source =
      yamlFormat.generate "deadd.yml" cfg.settings;

    xdg.configFile."deadd/deadd.css" = let
      inherit (config.colorScheme) colors;
      inherit (lib.my.color) hexToRgba rgbaToCSS withAlpha;
      hexColors = mapAttrs (_: c: "#${c}") colors;
      rgbaColors = mapAttrs (_: c: hexToRgba c) hexColors;
    in {
      text = ''
        * {
          font-family: ${cfg.font.name or "monospace"};
          font-size: 12px;
        }

        button {
          background: transparent;
          border-radius: 3px;
          border-width: 0px;
          background-position: 0px 0px;
          text-shadow: none;
          color: ${hexColors.base05};
          font-weight: bolder;
        }

        button:hover {
          background: ${hexColors.base02};
          border-color: ${hexColors.base02};
          color: ${hexColors.base05};
        }

        /*.blurredBG, .blurredBG.low, .blurredBG.normal*/
        /*${rgbaToCSS (withAlpha 0.5 rgbaColors.base01)};*/
        .noti-center {
          color: ${hexColors.base05};
          background: transparent;
          border-color: ${hexColors.base01};
        }

        .noti-center.time {
          font-size: 24px;
        }

        .noti-center.date {
          font-size: 18px;
        }

        .noti-center.delete-all {
          font-weight: bolder;
        }

        button.in-center.button-close {
          margin-right: 2px;
        }

        button.in-center.actionbutton {
          margin-right: 2px;
        }

        .appname {
          font-size: 12px;
        }

        .time {
          font-size: 12px;
        }

        .blurredBG {
          background: ${rgbaToCSS (withAlpha 0.8 rgbaColors.base01)};
        }

        .blurredBG.notification {
          background: ${rgbaToCSS (withAlpha 0.6 rgbaColors.base01)};
        }

        .notification.content {
          padding: 12px;
        }

        .notificationInCenter {
          border-width: 1px;
          padding: 4px;
          margin-right: 12px;
        }

        .notification.low,
        .notificationInCenter.low  {
          color: ${hexColors.base04};
          background: ${hexColors.base00};
          border-color: ${hexColors.base03};
        }

        .notification.normal,
        .notificationInCenter.normal {
          background: ${hexColors.base01};
          color: ${hexColors.base05};
          border-color: ${hexColors.base00};
        }

        .notification.critical,
        .notificationInCenter.critical {
          background: ${hexColors.base01};
          color: ${hexColors.base05};
          border-color: ${hexColors.base0E};
        }

        ${cfg.extraCSS}
      '';

      onChange = ''
        ${getExe helpers.style-reload} || true
      '';
    };
  };
}
