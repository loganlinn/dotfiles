{ pkgs, ... }: {
  systemd.user.services.polybar = {
    Install.WantedBy = [ "graphical-session.target" ];
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3GapsSupport = true;
      alsaSupport = true;
      pulseSupport = true;
      nlSupport = false;
      iwSupport = true;
      mpdSupport = true;
      githubSupport = true;
    };
    config = {
      "settings" = {
        screenchange-reload = true;
      };
      colors = {
        black = "\${xrdb:color0}";
        bblack = "\${xrdb:color8}";
        red = "\${xrdb:color1}";
        bred = "\${xrdb:color9}";
        green = "\${xrdb:color2}";
        bgreen = "\${xrdb:color10}";
        yellow = "\${xrdb:color3}";
        byellow = "\${xrdb:color11}";
        blue = "\${xrdb:color4}";
        bblue = "\${xrdb:color12}";
        magenta = "\${xrdb:color5}";
        bmagenta = "\${xrdb:color13}";
        cyan = "\${xrdb:color6}";
        bcyan = "\${xrdb:color14}";
        white = "\${xrdb:color7}";
        bwhite = "\${xrdb:color15}";
        bg = "\${xrdb:background}";
        # fg = "\${colors.magenta}";
        fg = "\${xrdb.foreground}";
        bg-alt = "#1E2029";
        fg-alt = "#373844";
        bg-dark = "#181a23";
        alert = "\${colors.yellow}";
        accent = "#604c7e";
      };
      "bar/top" = rec {
        width = "100%";
        height = "36";
        enable-ipc = true;
        background = "\${colors.bg}";
        foreground = "\${colors.fg}";
        radius = 0;
        font-size = "12";
        # font-0 = ":style=Regular:size=${font-size};5";
        # font-1 = "emoji:style=Regular:scale=10;4";
        # font-0 = "Hack Nerd Font:pixelsize=14:antialias=true;2.5";
        # font-1 = "Hack Nerd Font:style=Regular:pixelsize=24:antialias=true;3";
        font-0 = "DejaVu Sans:size=10;3";
        font-1 = "DejaVu Sans:size=10:style=Bold;3";
        font-2 = "FontAwesome:pixelsize=10;3";
        # font-3 = "Font Awesome 5 Free Regular:pixelsize=10;3";
        # font-4 = "Font Awesome 5 Free Solid:pixelsize=10;3";
        # font-5 = "Font Awesome 5 Brands:pixelsize=10;3";
        padding = 3;
        # https://en.wikipedia.org/wiki/Thin_space
        separator = " ";
        module-margin = 0;
        modules-left = [ "i3" ];
        modules-center = [ "time" ];
        modules-right = [ "memory" "cpu" "temperature" "volume" ];
        monitor = "\${env:MONITOR:}";
        # tray-padding = 2;
        # tray-maxsize = 512;
        tray-position = "right";
        tray-detached = false;
        tray-maxsize = 16;
        # scroll-up = "${pkgs.brillo}/bin/brillo -e -A 0.5";
        # scroll-down = "${pkgs.brillo}/bin/brillo -e -U 0.5";
        # override-redirect = true;
        # wm-restack = "i3";
      };
      "module/i3" = {
        type = "internal/i3";
        enable-click = true;
        index-sort = true;
        pin-workspaces = false; # only show workspaces on the current monitor
        reverse-scroll = false;
        show-urgent = true;
        strip-wsnumbers = true;
        wrapping-scroll = false;

        label-visible = "%name%";
        label-urgent = "%name%";
        label-focused = "%name%";
        label-unfocused = "%name%";
        label-focused-foreground = "\${colors.fg-alt}";
        label-focused-background = "\${colors.bg-alt}";
        label-urgent-background = "\${colors.alert}";
        label-focused-padding = 2;
        label-unfocused-padding = 2;
        label-visible-padding = 2;
        label-urgent-padding = 2;
      };
      "module/temperature" = rec {
        type = "internal/temperature";
        interval = 5;
        base-temperature = 40;
        warn-temperature = 70;
        units = true;
        format = "<ramp><label>";
        label = "%temperature-c%";
        format-warn = "<ramp><label-warn>";
        ramp-0 = " ";
        ramp-1 = " ";
        ramp-2 = " ";
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        # format-prefix = " ";
        format-padding = 2;
        label = "CPU %percentage%%";
      };
      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-padding = 2;
        # format-prefix = " ";
        label = "RAM %percentage_used%%";
        # label = "RAM %gb_used%/%gb_free%";
      };
      "module/time" = {
        type = "internal/date";
        interval = 1;
        format-padding = 3;
        time = "%H:%M";
        date = "%A %d %b";
        label = "%date%, %time%";
        label-padding = 2;
        # Bold font for date
        # This font is defined as font-1 but we actually need to say font = 2 here
        label-font = 2;
      };
      "module/network_eno3" = {
        type = "internal/network";
        interface = "eno3";
        interval = 5;
        # format-connected = " <label-connected>";
        # format-connected-background = background;
        # format-connected-padding = 2;
        # format-disconnected = "<label-disconnected>";
        # format-disconnected-background = alert;
        # format-disconnected-padding = 2;
        # label-connected = "%essid% %signal%%";
        # label-disconnected = "⚠ Disconnected";
      };
      "module/network_wlo1" = {
        type = "internal/network";
        interface = "wlo1";
        interval = 5;
        # format-connected = " <label-connected>";
        # format-disconnected = "<label-disconnected>";
        # format-disconnected-padding = 2;
        # label-connected = "%essid% %signal%%";
        # label-disconnected = "⚠ Disconnected";
      };
      # "module/pulseaudio" = {
      #   type = "internal/pulseaudio";
      #   format-volume = "<ramp-volume> <label-volume>";
      #   format-volume-padding = 2;
      #   format-muted = "<label-muted>";
      #   label-volume = "%percentage%%";
      #   label-muted = "";
      #   ramp-volume-0 = "";
      #   ramp-volume-1 = "";
      #   ramp-volume-2 = "";
      #   click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      #   scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
      #   scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
      # };
      # "module/pulseaudio" = {
      #   type = "internal/alsa";
      #   master-mixer = "Master";
      #   # headphone-id = 9;
      #   format-volume-padding = 2;
      #   format-muted-padding = 2;
      #   label-muted = "婢 Mute";
      #   ramp-volume-0 = "";
      #   ramp-volume-1 = "";
      #   ramp-volume-2 = "";
      #   format-volume-margin = 2;
      #   format-volume = "<ramp-volume> <label-volume>";
      #   label-volume = "%percentage%%";
      #   use-ui-max = false;
      #   interval = 5;
      # };
      "module/volume" = {
        type = "internal/pulseaudio";
        format-volume = "<ramp-volume> <label-volume>";
        label-muted-text = "🔇";
        label-muted-foreground = "#666";
        ramp-volume = [ "🔈" "🔉" "🔊" ];
        click-right = "pavucontrol &";
        # click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        # scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
        # scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
      };
      "module/powermenu" = {
        type = "custom/menu";
        expand-right = true;
        format-spacing = 1;
        format-margin = 0;
        format-padding = 2;
        label-open = "";
        label-close = "";
        label-separator = "|";
        #; reboot
        menu-0-1 = "";
        menu-0-1-exec = "menu-open-2";
        #; poweroff
        menu-0-2 = "";
        menu-0-2-exec = "menu-open-3";
        #; logout
        menu-0-0 = "";
        menu-0-0-exec = "menu-open-1";
        menu-2-0 = "";
        menu-2-0-exec = "reboot";
        menu-3-0 = "";
        menu-3-0-exec = "poweroff";
        menu-1-0 = "";
        menu-1-0-exec = "";
      };
    };
    script = ''
      for m in $(polybar --list-monitors | ${pkgs.coreutils-full}/bin/cut -d":" -f1); do
          MONITOR=$m polybar --reload top &
      done
    '';
  };
}
