{ config, lib, pkgs, nerdfonts, ... }:

# with lib;

let
  inherit (builtins) isNull toString;
  inherit (lib) mkIf optionalString mkOption;

  colors = (lib.mapAttrs (k: v: "#${v}") config.colorScheme.colors) // {
    transparent = "#00000000";
    background = "\${colors.base00}";
    background-alt = "\${colors.base01}";
    background-selection = "\${colors.base02}";
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
    font-2 = "Font Awesome 6 Free:style=Solid:pixelsize=11;2";
    font-3 = "Font Awesome 6 Free:style=Regular:pixelsize=11;2";
    font-4 = "Font Awesome 6 Brands:pixelsize=12;2";
    font-5 = "Symbols Nerd Font:size=12;3";
    font-6 = "Symbols Nerd Font:size=16;3";
    font-7 = "Symbols Nerd Font:style=Medium:size=16;3";
  };

  nerdfontIcon = text: "%{T6}${text}%{T-}";
  nerdfontBigIcon = text: "%{T7}${text}%{T-}";
  symbolsFont = text: "%{T8}${text}%{T-}";

  # common module gen function
  mkModule = type: config: {
    inherit type;
    background = "\${colors.background}";
    foreground = "\${colors.foreground}";
    format-background = "\${colors.background}";
    format-foreground = "\${colors.foreground}";
    format-prefix-foreground = "\${colors.foreground-dark}";
    format-suffix-foreground = "\${colors.foreground-dark}";
    format-padding = 2;
  } // config;

  mkModules = lib.mapAttrs' (name: value: {
    name = "module/${name}";
    value = value;
  });

in
{
  config = mkIf config.services.polybar.enable {

    services.polybar = {

      package = pkgs.polybarFull;

      script = ''
        # Terminate all running polybar instances.
        polybar-msg cmd quit 2>/dev/null || true

        monitors=$(polybar --list-monitors)

        MONITOR_PRIMARY=$(${pkgs.gnugrep}/bin/grep '\(primary\)' <<<"$monitors" | ${pkgs.coreutils}/bin/cut -d":" -f1)
        export MONITOR_PRIMARY

        for m in $(${pkgs.coreutils}/bin/cut -d":" -f1 <<<"$monitors"); do
          MONITOR=$m polybar --reload top &
        done
      '';

      config = {
        inherit colors;

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
          override-redirect = false;

          modules-left = [
            "title"
          ];

          modules-center = [
            "i3"
          ];

          modules-right = [
            "memory"
            "cpu"
            "temperature"
            "sep1"
            "pulseaudio"
            "sep2"
            "dunst"
            "sep3"
            "date"
          ];

          bottom = false;
          fixed-center = true;
          width = "100%";
          height = 36;
          offset-x = "0%";
          offset-y = "0%";

          spacing = 0;
          padding = 0;

          module-margin-left = 0;
          module-margin-right = 0;

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
      // mkModules {

        sep1 = {
          type = "custom/text";
          content = " ";
          content-foreground = "\${colors.transparent}";
          content-background = "\${colors.transparent}";
        };

        sep2 = {
          type = "custom/text";
          content = " ";
          content-foreground = "\${colors.transparent}";
          content-background = "\${colors.transparent}";
        };

        sep3 = {
          type = "custom/text";
          content = " ";
          content-foreground = "\${colors.transparent}";
          content-background = "\${colors.transparent}";
        };


        pulseaudio = mkModule "internal/pulseaudio" {
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
        };

        title = mkModule "internal/xwindow" {
          format-prefix = "${nerdfonts.md.dock_window} ";
          format = "<label>";
          label = "%title%";
          label-maxlen = 50;
          label-empty = "Empty";
          label-empty-foreground = "\${colors.foreground-dark}";
        };

        # Module settings (https://github.com/polybar/polybar/wiki/Configuration#module-settings)
        i3 = mkModule "internal/i3" {
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
          label-focused-underline = "\${colors.selection}";
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
        };

        date = mkModule "internal/date" {
          interval = 1;
          time = "%I:%M %p";
          date = "%a %b %d";
          time-alt = "%H:%M";
          date-alt = " %Y-%m-%d%";
          format = "<label>";
          # format-prefix = " ";
          label = "%date% %time%";
        };

        memory = mkModule "internal/memory" {
          interval = 2;
          format = "<label> <bar-used>";
          label = "%percentage_used%%";
          format-prefix = "RAM ";
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
        };

        gpu = mkModule "custom/script" {
          exec = ''
            /run/current-system/sw/bin/nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | ${pkgs.gawk}/bin/awk '{ print $1 "%"}'
          '';
          interval = 5;
          format-prefix = "GPU ";
        };

        cpu = mkModule "internal/cpu" {
          interval = 2;
          format-prefix = "CPU ";
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
        };

        temperature = mkModule "internal/temperature" {
          interval = 5;
          thermal-zone = "x86_pkg_temp";
          hwmon-path = "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp1_input";
          base-temperature = 50;
          warn-temperature = 75;
          format-prefix = "TEMP ";
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
        };

        dunst = {
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

        # inspired by https://github.com/sudo-kjp/nu-dotfiles/blob/f39f9190214d998875376e2e4fc1fe738838cec1/polybar/config.ini
        left-inner = {
          type = "custom/text";
          content-background = "\${colors.transparent}";
          content-foreground = "\${colors.background}";
          content = symbolsFont "";
        };

        left1 = {
          type = "custom/text";
          content-background = "\${colors.shade2}";
          content-foreground = "\${colors.shade1}";
          content = symbolsFont "";
        };

        left2 = {
          type = "custom/text";
          content-background = "\${colors.shade3}";
          content-foreground = "\${colors.shade2}";
          content = symbolsFont "";
        };

        left3 = {
          type = "custom/text";
          content-background = "\${colors.background}";
          content-foreground = "\${colors.shade3}";
          content = symbolsFont "";
        };

        right1 = {
          type = "custom/text";
          content-background = "\${colors.shade2}";
          content-foreground = "\${colors.shade1}";
          content = symbolsFont "";
        };

        right2 = {
          type = "custom/text";
          content-background = "\${colors.shade3}";
          content-foreground = "\${colors.shade2}";
          content = symbolsFont "";
        };

        right3 = {
          type = "custom/text";
          content-background = "\${colors.shade4}";
          content-foreground = "\${colors.shade3}";
          content = symbolsFont "";
        };

        right4 = {
          type = "custom/text";
          content-background = "\${colors.shade5}";
          content-foreground = "\${colors.shade4}";
          content = symbolsFont "";
        };

        # "right4.5" = {
        #   type = "custom/text";
        #   content-background = "\${colors.shade5}";
        #   content-foreground = "\${colors.shade5}";
        #   content = nerdfont "";
        # };

        right5 = {
          type = "custom/text";
          content-background = "\${colors.shade6}";
          content-foreground = "\${colors.shade5}";
          content = symbolsFont "";
        };

        right6 = {
          type = "custom/text";
          content-background = "\${colors.shade7}";
          content-foreground = "\${colors.shade6}";
          content = symbolsFont "";
        };

        right7 = {
          type = "custom/text";
          content-background = "\${colors.background}";
          content-foreground = "\${colors.shade7}";
          content = symbolsFont "";
        };

      };
      # extraConfig = ''
      #   ${let extraConfigDir = "${config.xdg.configHome}/polybar/config.d"; in
      #     lib.optionalString (lib.pathExists extraConfigDir)
      #       "include-directory = ${extraConfigDir}"}
      # '';
    };

    # HACK: setup PATH for scripts
    systemd.user.services.polybar.Service.Environment =
      let path = lib.makeBinPath [
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
      lib.mkForce "PATH=${path}";

    systemd.user.services.polybar.Install.WantedBy = [ "graphical-session.target" ];
  };

}
