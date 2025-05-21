{
  inputs,
  inputs',
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.hyprland;
  wl-paste = getExe' pkgs.wl-clipboard "wl-paste";
in
{
  imports = [
    inputs.hyprland.nixosModules.default
    ./options.nix
    ../../themes/Catppuccin # Catppuccin GTK and QT themes
    ./programs/waybar
    ./programs/wlogout
    ./programs/rofi
    ./programs/hypridle
    ./programs/hyprlock
    ./programs/swaync
    # ./programs/dunst
  ];

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  systemd.user.services.hyprpolkitagent = {
    description = "Hyprpolkitagent - Polkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  services.displayManager.defaultSession = "hyprland";

  programs.hyprland = {
    enable = true;
    package = inputs'.hyprland.packages.hyprland;
    portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;
  };

  home-manager.sharedModules = [
    inputs.hyprland.homeManagerModules.default
    {
      home.packages = with pkgs; [
        hyprpaper
        hyprpicker
        cliphist
        grimblast
        swappy
        libnotify
        brightnessctl
        networkmanagerapplet
        pamixer
        pavucontrol
        playerctl
        waybar
        wtype
        wl-clipboard
        xdotool
        yad
        socat
        jq
      ];

      xdg.configFile."hypr/icons" = {
        source = ./icons;
        recursive = true;
      };

      home.sessionVariables = {
        NIXOS_OZONE_WL = "1"; # hint Electron apps to use Wayland
      };

      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs'.hyprland.packages.hyprland;
        portalPackage = inputs'.hyprland.packages.xdg-desktop-portal-hyprland;
        # plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [
        #   # provides:
        #   #   moveorexec window, cmd
        #   #   throwunfocused workspace
        #   #   bringallfrom workspace
        #   #   closeunfocused
        #   xtra-dispatchers
        #   hyprexpo
        # ];
        systemd = {
          enable = true; # TODO https://wiki.hyprland.org/useful-utilities/systemd-start
          variables = [ "--all" ];
        };
        settings = {
          "$mainMod" = "SUPER";
          "$moveMod" = "SUPER SHIFT";
          "$moveSilentMod" = "SUPER SHIFT CTRL";
          "$hyper" = "ALT CTRL SHIFT SUPER";
          "$meh" = "ALT CTRL SHIFT SUPER";
          "$term" = cfg.terminal;
          "$editor" = cfg.editor;
          "$filemanager" = cfg.fileManager;
          "$browser" = cfg.browser;

          # low power mode:
          # decoration:blur:enabled = false
          # decoration:shadow:enabled = false
          # misc:vfr = true

          env = [
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"
            "GDK_BACKEND,wayland,x11,*"
            "NIXOS_OZONE_WL,1"
            "ELECTRON_OZONE_PLATFORM_HINT,auto"
            "MOZ_ENABLE_WAYLAND,1"
            "OZONE_PLATFORM,wayland"
            "EGL_PLATFORM,wayland"
            "CLUTTER_BACKEND,wayland"
            "SDL_VIDEODRIVER,wayland"
            "QT_QPA_PLATFORM,wayland;xcb"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_QPA_PLATFORMTHEME,qt6ct"
            "QT_AUTO_SCREEN_SCALE_FACTOR,1"
            "WLR_RENDERER_ALLOW_SOFTWARE,1"
            # "NIXPKGS_ALLOW_UNFREE,1"
          ];

          exec-once = [
            "waybar"
            "swaync"
            "nm-applet --indicator"
            "wl-clipboard-history -t"
            "${wl-paste} --type text --watch cliphist store" # clipboard store text data
            "${wl-paste} --type image --watch cliphist store" # clipboard store image data
            "rm '$XDG_CACHE_HOME/cliphist/db'" # Clear clipboard
            "${./scripts/batterynotify.sh}" # battery notification
            # "${./scripts/autowaybar.sh}" # uncomment packages at the top
            "polkit-agent-helper-1"
            "pamixer --set-volume 50"
            # TODO 1password (ssh-agent)
          ];

          input = {
            follow_mouse = 1;
            force_no_accel = true;
            kb_layout = "us";
            repeat_delay = 300;
            repeat_rate = 30;
            sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
            tablet.output = "current";
            touchpad.natural_scroll = false;
          };
          general = {
            gaps_in = 4;
            gaps_out = 9;
            border_size = 2;
            "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
            "col.inactive_border" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
            resize_on_border = true;
            layout = "dwindle"; # dwindle or master
            # allow_tearing = true; # Allow tearing for games (use immediate window rules for specific games or all titles)
          };
          decoration = {
            shadow.enabled = false;
            rounding = 10;
            dim_special = 0.3;
            blur = {
              enabled = true;
              special = true;
              size = 6; # 6
              passes = 2; # 3
              new_optimizations = true;
              ignore_opacity = true;
              xray = false;
            };
          };
          group = {
            "col.border_active" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
            "col.border_inactive" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
            "col.border_locked_active" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
            "col.border_locked_inactive" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
          };
          layerrule = [
            "blur, rofi"
            "ignorezero, rofi"
            "ignorealpha 0.7, rofi"
            "blur, swaync-control-center"
            "blur, swaync-notification-window"
            "ignorezero, swaync-control-center"
            "ignorezero, swaync-notification-window"
            "ignorealpha 0.7, swaync-control-center"
            # "ignorealpha 0.8, swaync-notification-window"
            # "dimaround, swaync-control-center"
          ];
          animations = {
            enabled = true;
            bezier = [
              "linear, 0, 0, 1, 1"
              "md3_standard, 0.2, 0, 0, 1"
              "md3_decel, 0.05, 0.7, 0.1, 1"
              "md3_accel, 0.3, 0, 0.8, 0.15"
              "overshot, 0.05, 0.9, 0.1, 1.1"
              "crazyshot, 0.1, 1.5, 0.76, 0.92"
              "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
              "fluent_decel, 0.1, 1, 0, 1"
              "easeInOutCirc, 0.85, 0, 0.15, 1"
              "easeOutCirc, 0, 0.55, 0.45, 1"
              "easeOutExpo, 0.16, 1, 0.3, 1"
            ];
            animation = [
              "windows, 1, 3, md3_decel, popin 60%"
              "border, 1, 10, default"
              "fade, 1, 2.5, md3_decel"
              # "workspaces, 1, 3.5, md3_decel, slide"
              "workspaces, 1, 3.5, easeOutExpo, slide"
              # "workspaces, 1, 7, fluent_decel, slidefade 15%"
              # "specialWorkspace, 1, 3, md3_decel, slidefadevert 15%"
              "specialWorkspace, 1, 3, md3_decel, slidevert"
            ];
          };
          render = {
            explicit_sync = 2; # 0 = off, 1 = on, 2 = auto based on gpu driver.
            explicit_sync_kms = 2; # 0 = off, 1 = on, 2 = auto based on gpu driver.
            direct_scanout = 2; # 0 = off, 1 = on, 2 = auto (on with content type ‘game’)
          };
          misc = {
            disable_hyprland_logo = true;
            mouse_move_focuses_monitor = true;
            swallow_regex = "^(Alacritty|kitty)$";
            enable_swallow = true;
            vfr = true; # always keep on
            vrr = 1; # enable variable refresh rate (0=off, 1=on, 2=fullscreen only)
          };
          xwayland.force_zero_scaling = false;
          gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 3;
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };
          master = {
            new_status = "master";
            new_on_top = true;
            mfact = 0.5;
          };
          windowrule = [
            #"noanim, class:^(Rofi)$
            "tile,title:(.*)(Godot)(.*)$"
            # "workspace 1, class:^(kitty|Alacritty|org.wezfurlong.wezterm)$"
            # "workspace 2, class:^(code|VSCodium|code-url-handler|codium-url-handler)$"
            # "workspace 3, class:^(krita)$"
            # "workspace 3, title:(.*)(Godot)(.*)$"
            # "workspace 3, title:(GNU Image Manipulation Program)(.*)$"
            # "workspace 3, class:^(factorio)$"
            # "workspace 3, class:^(steam)$"
            # "workspace 5, class:^(firefox|floorp|zen)$"
            # "workspace 6, class:^(Spotify)$"
            # "workspace 6, title:(.*)(Spotify)(.*)$"

            # Can use FLOAT FLOAT for active and inactive or just FLOAT
            "opacity 0.80 0.80,class:^(kitty|alacritty|Alacritty|org.wezfurlong.wezterm)$"
            "opacity 0.90 0.90,class:^(gcr-prompter)$" # keyring prompt
            "opacity 0.90 0.90,title:^(Hyprland Polkit Agent)$" # polkit prompt
            "opacity 1.00 1.00,class:^(firefox)$"
            "opacity 0.90 0.90,class:^(Brave-browser)$"
            "opacity 0.80 0.80,class:^(Steam)$"
            "opacity 0.80 0.80,class:^(steam)$"
            "opacity 0.80 0.80,class:^(steamwebhelper)$"
            "opacity 0.80 0.80,class:^(Spotify)$"
            "opacity 0.80 0.80,title:(.*)(Spotify)(.*)$"
            "opacity 0.80 0.80,class:^(VSCodium)$"
            "opacity 0.80 0.80,class:^(codium-url-handler)$"
            "opacity 0.80 0.80,class:^(code)$"
            "opacity 0.80 0.80,class:^(code-url-handler)$"
            "opacity 0.80 0.80,class:^(terminalFileManager)$"
            "opacity 0.80 0.80,class:^(org.kde.dolphin)$"
            "opacity 0.80 0.80,class:^(org.kde.ark)$"
            "opacity 0.80 0.80,class:^(nwg-look)$"
            "opacity 0.80 0.80,class:^(qt5ct)$"
            "opacity 0.80 0.80,class:^(qt6ct)$"
            "opacity 0.80 0.80,class:^(yad)$"

            "opacity 0.90 0.90,class:^(com.github.rafostar.Clapper)$" # Clapper-Gtk
            "opacity 0.80 0.80,class:^(com.github.tchx84.Flatseal)$" # Flatseal-Gtk
            "opacity 0.80 0.80,class:^(hu.kramo.Cartridges)$" # Cartridges-Gtk
            "opacity 0.80 0.80,class:^(com.obsproject.Studio)$" # Obs-Qt
            "opacity 0.80 0.80,class:^(gnome-boxes)$" # Boxes-Gtk
            "opacity 0.90 0.90,class:^(discord)$" # Discord-Electron
            "opacity 0.90 0.90,class:^(WebCord)$" # WebCord-Electron
            "opacity 0.80 0.80,class:^(app.drey.Warp)$" # Warp-Gtk
            "opacity 0.80 0.80,class:^(net.davidotek.pupgui2)$" # ProtonUp-Qt
            "opacity 0.80 0.80,class:^(Signal)$" # Signal-Gtk
            "opacity 0.80 0.80,class:^(io.gitlab.theevilskeleton.Upscaler)$" # Upscaler-Gtk

            "opacity 0.80 0.70,class:^(pavucontrol)$"
            "opacity 0.80 0.70,class:^(org.pulseaudio.pavucontrol)$"
            "opacity 0.80 0.70,class:^(blueman-manager)$"
            "opacity 0.80 0.70,class:^(.blueman-manager-wrapped)$"
            "opacity 0.80 0.70,class:^(nm-applet)$"
            "opacity 0.80 0.70,class:^(nm-connection-editor)$"
            "opacity 0.80 0.70,class:^(org.kde.polkit-kde-authentication-agent-1)$"

            "float,class:^(qt5ct)$"
            "float,class:^(nwg-look)$"
            "float,class:^(org.kde.ark)$"
            "float,class:^(Signal)$" # Signal-Gtk
            "float,class:^(com.github.rafostar.Clapper)$" # Clapper-Gtk
            "float,class:^(app.drey.Warp)$" # Warp-Gtk
            "float,class:^(net.davidotek.pupgui2)$" # ProtonUp-Qt
            "float,class:^(eog)$" # Imageviewer-Gtk
            "float,class:^(io.gitlab.theevilskeleton.Upscaler)$" # Upscaler-Gtk
            "float,class:^(yad)$"
            "float,class:^(pavucontrol)$"
            "float,class:^(blueman-manager)$"
            "float,class:^(.blueman-manager-wrapped)$"
            "float,class:^(nm-applet)$"
            "float,class:^(nm-connection-editor)$"
            "float,class:^(org.kde.polkit-kde-authentication-agent-1)$"
          ];
          binde = [
            # Resize windows
            "$mainMod SHIFT, right, resizeactive, 30 0"
            "$mainMod SHIFT, left, resizeactive, -30 0"
            "$mainMod SHIFT, up, resizeactive, 0 -30"
            "$mainMod SHIFT, down, resizeactive, 0 30"

            # Resize windows with hjkl keys
            "$mainMod SHIFT, l, resizeactive, 30 0"
            "$mainMod SHIFT, h, resizeactive, -30 0"
            "$mainMod SHIFT, k, resizeactive, 0 -30"
            "$mainMod SHIFT, j, resizeactive, 0 30"

            # Functional keybinds
            ",XF86MonBrightnessDown,exec,brightnessctl set 2%-"
            ",XF86MonBrightnessUp,exec,brightnessctl set +2%"
            ",XF86AudioLowerVolume,exec,pamixer -d 2"
            ",XF86AudioRaiseVolume,exec,pamixer -i 2"
          ];
          bindd = [
            "$CONTROL ALT, DELETE, System monitor, exec, ${cfg.processManager}'"
            "$CONTROL, ESCAPE, Toggle waybar, exec, pkill waybar || waybar" # toggle waybar
            "$mainMod ALT, Q, Kill window, forcekillactive"
            "$mainMod CTRL, F, Toggle fullscreen, fullscreen"
            "$mainMod CTRL, L, Lock, exec, hyprlock"
            "$mainMod CTRL, Q, Kill window picker, exec, hyprctl kill"
            "$mainMod CTRL, Return, Editor, exec, $editor"
            "$mainMod SHIFT, F, Toggle floating, togglefloating"
            "$mainMod SHIFT, G, Toggle group, togglegroup"
            "$mainMod SHIFT, Return, Web browser, exec, $browser"
            "$mainMod, E, File browser, exec, $fileManager"
            "$mainMod, F, Focus next, cyclenext"
            "$mainMod, F10, Disable night mode, exec, pkill hyprsunset"
            "$mainMod, F9, Enable night mode, exec, ${getExe pkgs.hyprsunset} --temperature 3500" # good values: 3500, 3000, 2500
            "$mainMod, P, Pin, pin"
            "$mainMod, Q, Close window, killactive"
            "$mainMod, Return, Terminal, exec, ${cfg.terminal}"
            "$mainMod, SPACE, Application launcher, exec, pkill -x rofi || ${./scripts/rofi.sh} drun"
            "$mainMod, Z, Emoji picker, exec, pkill -x rofi || ${./scripts/rofi.sh} emoji"
            "$mainMod, backslash, Clipboard manager, exec, ${./scripts/ClipManager.sh}"
            "$mainMod, backspace, Logout, exec, pkill -x wlogout || wlogout -b 4" # logout menu
            "$mainMod, question, Show keybinds, exec, ${./scripts/keybinds.sh}"
            # "$mainMod CTRL, C, Color picker, exec, hyprpicker --autocopy --format=hex"
            # "$mainMod, F6, Rename workspace, renameworkspace,"
          ];
          bind =
            [
              # "$mainMod, tab, exec, pkill -x rofi || ${./scripts/rofi.sh} window" # switch between desktop applications
              "$mainMod SHIFT, N, exec, swaync-client -t -sw" # swayNC panel
              "$mainMod SHIFT, Q, exec, swaync-client -t -sw" # swayNC panel

              # Screenshot/Screencapture
              ", Print, exec, ${./scripts/screenshot.sh} s" # drag to snip an area / click on a window to print it
              "$mainMod CTRL, P, exec, ${./scripts/screenshot.sh} sf" # frozen screen, drag to snip an area / click on a window to print it
              "$mainMod, print, exec, ${./scripts/screenshot.sh} m" # print focused monitor
              "$mainMod ALT, P, exec, ${./scripts/screenshot.sh} p" # print all monitor outputs

              # Functional keybinds
              ",XF86Sleep, exec, systemctl suspend"
              ",XF86AudioMicMute, exec, pamixer --default-source -t"
              ",XF86AudioMute, exec, pamixer -t"
              ",XF86AudioPlay, exec, playerctl play-pause"
              ",XF86AudioPause, exec, playerctl play-pause"
              ",xf86AudioNext, exec, playerctl next"
              ",xf86AudioPrev, exec, playerctl previous"

              # to switch between windows in a floating workspace
              "$mainMod, Tab, cyclenext"
              "$mainMod, Tab, bringactivetotop"

              "$mainMod, rightbracket, workspace, r+1"
              "$mainMod, leftbracket, workspace, r-1"
              "$moveMod, rightbracket, movetoworkspace, r+1"
              "$moveMod, leftbracket, movetoworkspace, r-1"
              "$moveSilentMod, rightbracket, movetoworkspacesilent, r+1"
              "$moveSilentMod, leftbracket, movetoworkspacesilent, r-1"

              # first empty workspace
              "$mainMod, minus, workspace, empty"
              "$moveMod, minus, movetoworkspace, empty"
              "$moveSilentMod, minus, movetoworkspacesilent, empty"

              # Move focus with MOD + arrow keys
              "$mainMod, left, movefocus, l"
              "$mainMod, right, movefocus, r"
              "$mainMod, up, movefocus, u"
              "$mainMod, down, movefocus, d"
              "ALT, Tab, movefocus, d"

              # Move focus with MOD + HJKL keys
              "$mainMod, h, movefocus, l"
              "$mainMod, l, movefocus, r"
              "$mainMod, k, movefocus, u"
              "$mainMod, j, movefocus, d"

              # Go to workspace 6 and 7 with mouse side buttons
              "$mainMod, mouse:276, workspace, 5"
              "$mainMod, mouse:275, workspace, 6"
              "$mainMod SHIFT, mouse:276, movetoworkspace, 5"
              "$mainMod SHIFT, mouse:275, movetoworkspace, 6"
              "$moveSilentMod, mouse:276, movetoworkspacesilent, 5"
              "$moveSilentMod, mouse:275, movetoworkspacesilent, 6"

              # Scroll through existing workspaces with MOD + scroll
              "$mainMod, mouse_down, workspace, e+1"
              "$mainMod, mouse_up, workspace, e-1"

              # Move active window to a relative workspace with MOD + CTRL + ALT + [←→]
              "$mainMod CTRL ALT, right, movetoworkspace, r+1"
              "$mainMod CTRL ALT, left, movetoworkspace, r-1"

              # Move active window around current workspace with MOD + SHIFT + CTRL [←→↑↓]
              "$mainMod SHIFT $CONTROL, left, movewindow, l"
              "$mainMod SHIFT $CONTROL, right, movewindow, r"
              "$mainMod SHIFT $CONTROL, up, movewindow, u"
              "$mainMod SHIFT $CONTROL, down, movewindow, d"

              # Move active window around current workspace with MOD + SHIFT + CTRL [HLJK]
              "$mainMod SHIFT $CONTROL, H, movewindow, l"
              "$mainMod SHIFT $CONTROL, L, movewindow, r"
              "$mainMod SHIFT $CONTROL, K, movewindow, u"
              "$mainMod SHIFT $CONTROL, J, movewindow, d"

              # Special workspaces (scratchpad)
              "$moveMod, Grave, movetoworkspacesilent, special"
              "$mainMod, Grave, togglespecialworkspace,"
            ]
            ++ (builtins.concatLists (
              builtins.genList (
                x:
                let
                  ws =
                    let
                      c = (x + 1) / 10;
                    in
                    builtins.toString (x + 1 - (c * 10));
                in
                [
                  "$mainMod, ${ws}, workspace, ${toString (x + 1)}"
                  "$mainMod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                  "$mainMod CTRL, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
                ]
              ) 10
            ));
          bindm = [
            # Move/Resize windows with MOD + LMB/RMB and dragging
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];
        };
        extraConfig = ''
          binds {
            workspace_back_and_forth = 1
            #allow_workspace_cycles=1
            #pass_mouse_when_bound=0
          }

          monitor=,preferred,auto,1
        '';
      };
    }
  ];
}
