{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
# test using https://tests.peter.sh/notification-generator/
  let
    inherit (lib.my) coalesce;

    inherit (config.colorScheme) palette;

    font =
      config.my.fonts.dunst
      or config.my.fonts.dunst
      or config.my.fonts.notifications
      or config.my.fonts.mono;

    cfg = config.services.dunst;
  in {
    services.dunst = {
      iconTheme = config.gtk.iconTheme;
      settings = {
        global = {
          browser = "${pkgs.xdg-utils}/bin/xdg-open";
          # browser = getExe config.programs.qutebrowser.package;
          dmenu = mkIf config.programs.rofi.enable "${config.programs.rofi.finalPackage}/bin/rofi -dmenu -p dunst:";
          monitor = 0;
          follow = "none";
          font = "${
            if font.name != null
            then font.name
            else "monospace"
          }${optionalString (font.size != null) " ${toString font.size}"}";
          # For a complete markup reference, see <https://docs.gtk.org/Pango/pango_markup.html>.
          # %a appname
          # %s summary
          # %b body
          # %i iconname (including its path)
          # %I iconname (without its path)
          # %p progress value ([ 0%] to [100%])
          # %n progress value without any extra characters
          # %% Literal %
          format = "<b>%s</b>\\n%b";
          icon_theme = "${config.gtk.iconTheme.name}, Adwaita";
          frame_width = 2;
          gap_size = 5;
          width = 480;
          height = 320;
          # The origin of the notification window on the screen. It can then be moved with offset.
          # Origin can be one of:
          #         top-left
          #         top-center
          #         top-right
          #         bottom-left
          #         bottom-center
          #         bottom-right
          #         left-center
          #         center
          #         right-center
          origin = "top-right";
          offset = "24x48";
          # origin = "top-center";
          # offset = "0x40";
          corner_radius = 0;
          padding = 12;
          horizontal_padding = 16;
          icon_position = "right";
          text_icon_padding = 0;
          progress_bar = true;
          progress_bar_height =
            (
              if font.size != null
              then font.size
              else 10
            )
            + 2;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          indicate_hidden = true;
          notification_limit = 8;
          min_icon_size = 0;
          max_icon_size = 42;
          markup = "full";
          separator_height = 4;
          transparency = 0;
          vertical_alignment = "center";
          show_age_threshold = 60;
          idle_threshold = "1m"; # Don't timeout notifications if user is idle longer than this time.
          alignment = "left";
          ellipsize = "middle";
          ignore_newline = false;
          line_height = 1; # The amount of extra spacing between text lines in pixels. Set to 0 to disable.
          word_wrap = true;
          sort = true;
          shrink = false;
          sticky_history = true;
          history_length = 50;
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = true; # Show an indicator if a notification contains actions and/or open-able URLs. See ACTIONS below for further details.

          # | action        | description
          # |---------------|------------
          # | none          | Don't do anything.
          # | do_action     | Invoke the action determined by the action_name rule. If there is no such action, open the context menu.
          # | open_url      | If the notification has exactly one url, open it. If there are multiple ones, open the context menu.
          # | close_current | Close current notification.
          # | close_all     | Close all notifications.
          # | context       | Open context menu for the notification.
          # | context_all   | Open context menu for all notifications.
          #
          mouse_left_click = "open_url, close_current";
          mouse_middle_click = "close_current";
          mouse_right_click = "do_action, close_current";

          separator_color = "auto";

          background = "#${palette.base01}";
          foreground = "#${palette.base05}";
          highlight = "#${palette.base0B}"; # i.e. progress bar
          frame_color = "#${palette.base01}";

          script = getExe (pkgs.writeShellScriptBin "dunst-global" ''
            export > ''${XDG_RUNTIME_DIR-/tmp}/dunst-script.env
          '');
        };

        urgency_low = {
          background = "#${palette.base00}";
          foreground = "#${palette.base04}";
          frame_color = "#${palette.base03}";
          timeout = 10;
        };

        urgency_normal = {
          background = "#${palette.base01}";
          foreground = "#${palette.base05}";
          frame_color = "#${palette.base0A}";
          timeout = 60;
        };

        urgency_critical = {
          background = "#${palette.base01}";
          foreground = "#${palette.base05}";
          frame_color = "#${palette.base0E}";
          timeout = 0;
        };

        slack = {
          appname = "Slack";
          new_icon = "${./icons/slack.svg}";
        };

        linear = {
          summary = "*Linear*";
          timeout = 60;
          new_icon = "${./icons/linear.svg}";
        };
      };
    };

    systemd.user.services.dunst.Service.ExecStart = mkForce "${cfg.package}/bin/dunst -config ${cfg.configFile} -verbosity info --startup_notification";
  }
