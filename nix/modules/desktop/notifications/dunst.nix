{ config, lib, pkgs, ... }:

with lib;

{
  config = lib.mkIf config.services.dunst.enable {
    services.dunst = {
      settings = rec {
        global = {
          browser = "${pkgs.xdg-utils}/bin/xdg-open";
          dmenu = "${config.programs.rofi.package}/bin/rofi -dmenu -p dunst:";
          monitor = 0;
          follow = "none";
          font = with config.modules.theme.fonts.mono; "${name} ${toString size}";
          format = "<b>%s</b>\\n%b";
          frame_color = "#282a36";
          icon_theme = config.gtk.iconTheme.name;
          frame_width = 1;
          gap_size = 2;
          width = 300;
          height = 300;
          offset = "10x50";
          origin = "top-right";
          padding = 8;
          horizontal_padding = 8;
          text_icon_padding = 0;
          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          indicate_hidden = true;
          notification_limit = 8;
          min_icon_size = 0;
          max_icon_size = 18;
          markup = "full";
          separator_color = "frame";
          separator_height = 2;
          transparency = 0;
          vertical_alignment = "center";
          show_age_threshold = 60;
          alignment = "left";
          ellipsize = "middle";
          ignore_newline = false;
          word_wrap = true;
          sticky_history = true;
          history_length = 50;
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = false;
          title = "Dunst";
          class = "Dunst";
          mouse_left_click = "do_action, close_current";
          # mouse_middle_click = "context";
          mouse_middle_click = "do_action";
          mouse_right_click = "close_current";
        };

        urgency_low = {
          # background = "#282a36";
          # foreground = "#6272a4";
          foreground = "#D8DEE9"; # nord4
          background = "#4C566A"; # nord3
          timeout = 10;
        };

        urgency_normal = {
          # background = "#1d1f21";
          # foreground = "#70a040";
          foreground = "#ECEFF4"; # nord6
          background = "#5E81AC"; # nord10
          frame_color = "#3B4252"; # nord1
          timeout = 60;
        };

        urgency_critical = {
          foreground = "#3B4252"; # nord1
          background = "#B48EAD"; # nord15
          timeout = 0;
        };

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
