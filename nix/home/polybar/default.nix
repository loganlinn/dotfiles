{ config, lib, pkgs, ... }:

with lib;

let
  onedark = import ../../modules/themes/colors/onedark.nix;
  dunst-snooze = import ./dunst-snooze.nix { inherit pkgs; dunst = config.services.dunst.package; };
  awk = "${pkgs.gawk}/bin/awk";
  cut = "${pkgs.coreutils-full}/bin/cut";
  nvidia-smi = "/run/current-system/sw/bin/nvidia-smi";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  polybar = "${config.services.polybar.package}/bin/polybar";
  polybar-msg = "${config.services.polybar.package}/bin/polybar-msg";

  # https://fontawesome.com/v6/icons
  fa = {
    alarm-clock = "";
    alient-8bit = "";
    arrow-down-to-line = "";
    backward = "";
    bell = "";
    bolt = "";
    bookmark = "";
    bug = "";
    calendar = "";
    camera = "";
    caret-up = "";
    check = "";
    circle = "";
    circle-down = "";
    circle-exclamation = "";
    circle-half-stroke = "";
    circle-info = "";
    circle-up = "";
    circle-user = "";
    circle-xmark = "";
    clock = "";
    cloud = "";
    code = "";
    comment = "";
    comments = "";
    desktop = "";
    docker = "";
    download = "";
    expand = "";
    film = "";
    flag = "";
    folder = "";
    folder-open = "";
    font = "";
    forward = "";
    gamepad = "";
    gauge = "";
    gear = "";
    gears = "";
    ghost = "";
    github = "";
    grid-2 = "";
    headphones = "";
    house = "";
    inbox = "";
    info = "";
    joystick = "";
    key = "";
    laptop = "";
    lock = "";
    minus = "";
    money-bill = "";
    moon = "";
    moon-stars = "";
    mug-hot = "";
    mug-saucer = "";
    network-wired = "";
    paperclip = "";
    pause = "";
    pen = "";
    pen-fancy = "";
    pen-to-square = "";
    phone-volume = "";
    plane = "";
    plane-up = "";
    plane-up-slash = "";
    play = "";
    playpause = "";
    plus = "+";
    power-off = "";
    print = "";
    quote-left = "";
    right-to-bracket = "";
    rocket-launch = "";
    server = "";
    share = "";
    share-from-square = "";
    slack = "";
    sliders = "";
    sparkles = "";
    star = "";
    tags = "";
    text = "";
    thumbs-down = "";
    thumbs-up = "";
    toggle-large-off = "";
    toggle-large-on = "";
    toggle-off = "";
    toggle-on = "";
    trash = "";
    umbrella = "";
    upload = "";
    user = "";
    video = "";
    volume-high = "";
    volume-low = "";
    volume-off = "";
    volume-xmark = "";
    wifi = "";
    wifi-exclamation = "";
    wifi-fair = "";
    wifi-slash = "";
    wifi-weak = "";
    xmark = "";
  };
in
{
  systemd.user.services.polybar = {
    Install.WantedBy = [ "graphical-session.target" ];
  };

  services.polybar = {
    enable = mkDefault true;

    package = pkgs.polybarFull;
    # package = pkgs.polybar.override {
    #   i3GapsSupport = config.xsession.windowManager.i3.enable;
    #   alsaSupport = true;
    #   pulseSupport = true;
    #   nlSupport = false;
    #   iwSupport = true;
    #   mpdSupport = true;
    #   githubSupport = true;
    # };

    config =
      let
        module = name: config: {
          name = "module/${name}";
          value = {
            type =
              if (hasAttr "exec" config) then
                "custom/script"
              else
                "internal/${name}";

            format-padding = 1;
            format-prefix-foreground = onedark.commentGrey;
          } // config;
        };
      in
      {
        # Application settings (https://github.com/polybar/polybar/wiki/Configuration#application-settings)
        settings = { screenchange-reload = true; };

        # Custom variables (https://github.com/polybar/polybar/wiki/Configuration#custom-variables)
        colors =
          # Xresources
          listToAttrs
            (forEach (range 0 15) (n: {
              name = "color${toString n}";
              value = "\${xrdb:color${toString n}}";
            })) // {
            background = onedark.background;
            foreground = onedark.foreground;
            focused-background = onedark.visualGrey;
            focused-foreground = onedark.blue;
            mode-background = onedark.darkYellow;
            mode-foreground = onedark.black;
            separator-background = onedark.background;
            separator-foreground = onedark.vertSplit;
            unfocused-background = onedark.background;
            unfocused-foreground = onedark.commentGrey;
            urgent-background = onedark.background;
            urgent-foreground = onedark.lightRed;
            visible-background = onedark.background;
            visible-foreground = onedark.foreground;
          };

        # Bar settings (https://github.com/polybar/polybar/wiki/Configuration#bar-settings)
        bar = {
          fill = "⏽";
          empty = "⏽";
          indicator = "⏽";
        };
        "bar/top" = {
          monitor = "\${env:MONITOR:}"; # see script
          width = "100%";
          height = "36";
          bottom = false;
          enable-ipc = true;
          radius = 0;
          font-size = "12";
          # font-0 = "DejaVuSansMono Nerd Font:size=10;3";
          # font-1 = "DejaVuSansMono Nerd Font:size=10:style=Bold;3";
          font-0 = "JetBrainsMono Nerd Font:size=10;3";
          font-1 = "JetBrainsMono Nerd Font:size=10:style=Bold;3";
          font-2 = "FontAwesome:pixelsize=10;3";
          font-5 = "JetBrainsMono Nerd Font:size=19;5";
          font-6 = "JetBrainsMono Nerd Font:style=Normal:size=12;3";
          font-7 = "Material Icons:size=11;4";
          font-8 =
            "JetBrainsMono Nerd Font:style=Medium Italic:size=15;4"; # round icons
          padding = 3;
          separator = " ";
          module-margin = 0;
          modules-left = [ "i3" ];
          modules-center = [ "date" ];
          modules-right = [ "memory" "gpu" "cpu" "temperature" "pulseaudio" "dunst-snooze" ];
          tray-position = "right";
          tray-detached = false;
          tray-maxsize = 16;
          background = "\${colors.background}";
          foreground = "\${colors.foreground}";
          cursor-click = "pointer"; # hand
          cursor-scroll = "ns-resize"; # arrows
        };
      } // listToAttrs [
        # Module settings (https://github.com/polybar/polybar/wiki/Configuration#module-settings)
        (module "i3" {
          enable-click = true;
          enable-scroll = false;
          index-sort = true;
          pin-workspaces = false; # only show workspaces on the current monitor
          reverse-scroll = false;
          show-urgent = true;
          strip-wsnumbers = false;
          wrapping-scroll = false;
          fuzzy-match = true;
          label-focused = "%name%";
          label-focused-background = "\${colors.focused-background}";
          label-focused-font = 2;
          label-focused-foreground = "\${colors.focused-foreground}";
          label-focused-padding = 2;
          label-mode = "%mode%";
          label-mode-background = "\${colors.mode-background}";
          label-mode-font = 1;
          label-mode-foreground = "\${colors.mode-foreground}";
          label-mode-padding = 2;
          label-separator-background = "\${colors.separator-background}";
          label-separator-font = 1;
          label-separator-foreground = "\${colors.separator-foreground}";
          label-separator-padding = 0;
          label-unfocused = "%name%";
          label-unfocused-background = "\${colors.unfocused-background}";
          label-unfocused-font = 1;
          label-unfocused-foreground = "\${colors.unfocused-foreground}";
          label-unfocused-padding = 2;
          label-urgent = "%name%";
          label-urgent-background = "\${colors.urgent-background}";
          label-urgent-font = 1;
          label-urgent-foreground = "\${colors.urgent-foreground}";
          label-urgent-padding = 2;
          label-visible = "%name%";
          label-visible-background = "\${colors.urgent-foreground}";
          label-visible-foreground = "\${colors.urgent-foreground}";
          label-visible-padding = 2;
        })
        (module "date" {
          interval = 1;
          time = "%I:%M %p";
          date = "%a %b %d";
          format-prefix = " ";
          label = "%date% %time%";
          label-font = 6;
        })
        (module "memory" {
          interval = 2;
          label = "%percentage_used%%";
          # format-prefix = "%{T7} %{T-}";
          format-prefix = "RAM ";
        })
        (module "gpu" {
          exec = ''
            ${nvidia-smi} --query-gpu=utilization.gpu --format=csv,noheader,nounits | ${awk} '{ print $1 "%"}'
          '';
          interval = 5;
          # format-prefix = "%{T7} %{T-}";
          format-prefix = "GPU ";
        })
        (module "cpu" {
          interval = 2;
          label = "%percentage%%";
          # format-prefix = "%{T7} %{T-}";
          format-prefix = "CPU ";
        })
        (module "temperature" {
          interval = 5;
          thermal-zone = "x86_pkg_temp";
          hwmon-path =
            "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp1_input";
          base-temperature = 50;
          warn-temperature = 75;
          units = true;
          format = "<ramp> <label>";
          label = "%temperature-c%";
          format-warn = "<ramp> <label-warn>";
          ramp-0 = "";
          ramp-1 = "";
          ramp-2 = "";
          ramp-0-foreground = onedark.white;
          ramp-1-foreground = onedark.lightYellow;
          ramp-2-foreground = onedark.lightRed;
        })
        (module "pulseaudio" {
          interval = 5;
          format-volume = "<ramp-volume> <label-volume>";
          use-ui-max = false; # use PA_VOLUME_NORM (100%)
          # label-muted = "%{T7}婢 %{T-} Mute";
          # ramp-volume-0 = "%{T7}奄%{T-}";
          # ramp-volume-1 = "%{T7}奔%{T-}";
          # ramp-volume-2 = "%{T7}奔%{T-}";
          # ramp-volume-3 = "%{T7}墳%{T-}";
          # label-muted = ""; # fa-volume-xmark
          label-muted = ""; # fa-volume-slash
          ramp-volume-0 = " ";
          ramp-volume-1 = " ";
          ramp-volume-2 = " ";
          ramp-volume-3 = " ";
          click-right = "${pavucontrol} &";
        })
        (module "dunst-snooze" {
          type = "custom/ipc";
          hook-0 = "${dunst-snooze}/bin/dunst-snooze";
          hook-1 = "${dunst-snooze}/bin/dunst-snooze --toggle";
          initial = 1;
          click-left = "#dunst-snooze.hook.1";
        })
        # (module "demo" {
        #   type = "custom/ipc";
        #   hook-0 = "echo foobar";
        #   hook-1 = "date +%s";
        #   hook-2 = "whoami";
        #   initial = 1;
        #   click-left = "#demo.hook.0";
        #   click-right = "#demo.hook.1";
        #   double-click-left = "#demo.hook.2";
        # })
        (module "powermenu" {
          type = "custom/menu";
          expand-right = true;
          format-spacing = 1;
          format-margin = 0;
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
        })
      ];

    script = ''
      ${polybar-msg} cmd quit
      for m in $(${polybar} --list-monitors | ${cut} -d":" -f1); do
          MONITOR=$m ${polybar} --reload top 2>&1 >"/tmp/polybar-top_$m.log" &
      done
    '';
  };
}
