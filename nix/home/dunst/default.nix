{ config, lib, pkgs, ... }:

with lib;

# test using https://tests.peter.sh/notification-generator/
let
  inherit (config.colorScheme) colors;
in
{
  services.dunst = {
    enable = true;

    iconTheme = config.gtk.iconTheme;

    settings = {
      global = {
        browser = "${pkgs.xdg-utils}/bin/xdg-open";
        dmenu = "${config.programs.rofi.finalPackage}/bin/rofi -dmenu -p dunst:";
        monitor = 0;
        follow = "none";
        font = with (config.my.fonts.notifications or config.my.fonts.mono);
          "${name}${optionalString (size != null) " ${toString size}"}";
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
        gap_size = 2;
        width = 440;
        height = "(24, 320)";
        offset = "-36, +36";
        origin = "top-right";
        corner_radius = 2;
        padding = 12;
        horizontal_padding = 16;
        icon_position = "right";
        text_icon_padding = 0;
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        indicate_hidden = true;
        notification_limit = 8;
        min_icon_size = 0;
        max_icon_size = 64;
        markup = "full";
        separator_height = 4;
        transparency = 0;
        vertical_alignment = "center";
        show_age_threshold = 60;
        alignment = "left";
        ellipsize = "middle";
        ignore_newline = false;
        line_height = 0;
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
        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "close_current";
        mouse_right_click = "context";

        separator_color = "auto";

        background = "#${colors.base01}";
        foreground = "#${colors.base05}";
        highlight = "#${colors.base0B}"; # i.e. progress bar
        frame_color = "#${colors.base01}";
      };

      urgency_low = {
        background = "#${colors.base00}";
        foreground = "#${colors.base04}";
        frame_color = "#${colors.base03}";
        timeout = 10;
      };

      urgency_normal = {
        background = "#${colors.base01}";
        foreground = "#${colors.base05}";
        frame_color = "#${colors.base09}";
        timeout = 60;
      };

      urgency_critical = {
        background = "#${colors.base01}";
        foreground = "#${colors.base05}";
        frame_color = "#${colors.base09}";
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
}
