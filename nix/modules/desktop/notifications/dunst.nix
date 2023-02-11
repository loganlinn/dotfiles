{ inputs, config, lib, pkgs, ... }:

with lib;

# test colors using https://tests.peter.sh/notification-generator/
let inherit (config.modules.theme) fonts colors;
in
{
  config = lib.mkIf config.services.dunst.enable {
    services.dunst = {
      settings = rec {
        global = {
          browser = "${pkgs.xdg-utils}/bin/xdg-open";
          dmenu = "${config.programs.rofi.package}/bin/rofi -dmenu -p dunst:";
          monitor = 0;
          follow = "none";
          font = "${fonts.mono.name} 10";
          format = "<b>%s</b>\\n%b";
          icon_theme = config.gtk.iconTheme.name;
          frame_width = 1;
          gap_size = 2;
          width = 440;
          height = "(24, 320)";
          offset = "-26, +26";
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
          show_indicators = true;
          title = "Dunst";
          class = "Dunst";
          mouse_left_click = "do_action, close_current";
          # mouse_middle_click = "context";
          mouse_middle_click = "do_action";
          mouse_right_click = "close_current";

          # frame_color = colors.types.border;
          # separator_color = "auto";
          separator_color = "frame";

          frame_color = "${colors.types.border}";
          background = "${colors.types.panelbg}";
          foreground = "${colors.types.panelfg}";
        };

        urgency_low = {
          # frame_color = "#3B7C87";
          # foreground = "#3B7C87";
          # background = "#191311";
          # background = "#282a36";
          # foreground = "#6272a4";
          # foreground = "#D8DEE9"; # nord4
          # background = "#4C566A"; # nord3
          # background = "${colors.types.bg}";
          # foreground = "${colors.types.fg}";
          timeout = 10;
        };

        urgency_normal = {
          # frame_color = "#5B8234";
          # foreground = "#5B8234";
          # background = "#191311";
          # background = "#1d1f21";
          # foreground = "#70a040";
          # foreground = "#ECEFF4"; # nord6
          # background = "#5E81AC"; # nord10
          # frame_color = "#3B4252"; # nord1
          frame_color = "${colors.types.highlight}";
          # background = "${colors.types.panelbg}";
          # foreground = "${colors.types.panelfg}";
          timeout = 60;
        };

        urgency_critical = {
          # frame_color = "#B7472A";
          # foreground = "#B7472A";
          # background = "#191311";
          # foreground = "#3B4252"; # nord1
          # background = "#B48EAD"; # nord15
          # background = "#cc6666";
          # foreground = "${colors.types.panelbg}";
          frame_color = "${colors.types.warning}";
          timeout = 0;
        };

        # log_script = {

        # };

        slack_cicd_fail = {
          appname = "Slack";
          summary = "*feeds-cicd*";
          body = "*fail*";
          foreground = "#3B4252";
          background = "#D08770";
          timeout = 120;
          set_stack_tag = "slack_feeds_cicd";
        };

        slack_cicd_success = {
          appname = "Slack";
          summary = "*feeds-cicd*";
          body = "*succeed*";
          foreground = "#3B4252";
          background = "#A3BE8C";
          timeout = 30;
          set_stack_tag = "slack_feeds_cicd";
        };

        slack_cicd_running = {
          appname = "Slack";
          summary = "*feeds-cicd*";
          body = "*running*";
          foreground = "#ECEFF4";
          background = "#4C566A";
          timeout = 4;
          set_stack_tag = "slack_feeds_cicd";
        };

        slack_cicd_skipped = {
          appname = "Slack";
          summary = "*feeds-cicd*";
          body = "*skipped*";
          skip_display = true;
          history_ignore = true;
          set_stack_tag = "slack_feeds_cicd";
        };

        slack_cicd_not_started = {
          appname = "Slack";
          summary = "*feeds-cicd*";
          body = "*not started*";
          skip_display = true;
          history_ignore = true;
          set_stack_tag = "slack_feeds_cicd";
        };

        slack_github = {
          appname = "Slack";
          summary = "*feeds-github*";
          timeout = 30;
          new_icon = "~/.local/share/icons/GitHub-Mark-32px.png";
        };

        slack_dd_alerts = {
          appname = "Slack";
          summary = "*alerts-datadog*";
          timeout = 30;
          #new_icon       =  ~/.local/share/icons/Datadog_Mark.png;
        };

        slack_az_alerts = {
          appname = "Slack";
          summary = "*alerts-azure*";
          timeout = 30;
          #new_icon       =  ~/.local/share/icons/Azure_Mark.png;
        };

        slack = {
          appname = "Slack";
          new_icon = "~/.local/share/icons/Slack_Mark.png";
        };

        linear = {
          summary = "*Linear*";
          timeout = 60;
          new_icon = "~/.local/share/icons/Linear-app-icon.png";
        };
      };
    };
  };
}
