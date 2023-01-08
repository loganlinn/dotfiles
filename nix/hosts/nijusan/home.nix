{ config, lib, pkgs, ... }:
let
  inherit (lib) getExe;

  bins = rec {
    kitty = getExe config.programs.kitty.package;
    rofi = getExe config.programs.rofi.package;
    google_chrome = getExe config.programs.google-chrome.package;
    emacs = getExe config.programs.emacs.package;
    neovim = getExe config.programs.neovim.package;

    terminal = kitty;
    browser = google_chrome;
  };
in {
  imports = [
    ../../home/3d-graphics.nix
    ../../home/browser.nix
    ../../home/common.nix
    ../../home/dev.nix
    ../../home/emacs.nix
    ../../home/fonts.nix
    ../../home/gh.nix
    ../../home/git.nix
    ../../home/i3
    ../../home/kitty
    ../../home/nnn.nix
    ../../home/pretty.nix
    ../../home/rofi.nix
    ../../home/sync.nix
    ../../home/tray.nix
    ../../home/vpn.nix
    ../../home/vscode.nix
    ../../home/xdg.nix
    ../../home/zsh.nix
  ];

  programs.rofi.enable = true;
  programs.feh.enable = true;

  home.sessionVariables."BROWSER" = bins.browser;

  xsession.enable = true;
  xsession.windowManager.i3 = let
    keysyms = {
      alt = "Mod1";
      super = "Mod4";
      # directions = {
      #   left = [ "Left" "h" ];
      #   down = [ "Down" "j" ];
      #   up = [ "Up" "k" ];
      #   right = [ "Right" "l" ];
      # };
    };

    quitModeKeybinds = {
      "Escape" = "mode default";
      "Ctrl+c" = "mode default";
      "Ctrl+g" = "mode default";
    };

    resizeKeybinds = { wider, narrower, taller, shorter }: {
      "${narrower}" = "resize shrink width 10px or 2 ppt";
      "${taller}" = "resize grow height 10px or 2 ppt";
      "${shorter}" = "resize shrink height 10px or 2 ppt";
      "${wider}" = "resize grow width 10px or 2 ppt";

      "Shift+${narrower}" = "resize shrink width 50px or 10 ppt";
      "Shift+${taller}" = "resize grow height 50px or 10 ppt";
      "Shift+${shorter}" = "resize shrink height 50px or 10 ppt";
      "Shift+${wider}" = "resize grow width 50px or 10 ppt";
    };
  in {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      terminal = bins.terminal;
      menu = "${bins.rofi} -show drun";
      modifier = keysyms.super;
      keybindings = with keysyms;
        lib.mkOptionDefault {
          "${super}+Return" = "exec ${bins.kitty}";
          "${super}+Shift+Return" = "exec ${bins.browser}";
          "${super}+e" = "exec ${bins.emacs}";
          "${super}+Shift+n" = "exec thunar";
          "${super}+space" = "exec ${bins.rofi} -show drun";
          "${super}+Shift+space" = "exec ${bins.rofi} -show run";
          "${super}+Ctrl+space" = "exec ${bins.rofi} -show window";
          "${super}+Shift+q" = "kill";
          "${super}+${alt}+q" =
            "exec --no-startup-id kill -9 $(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowpid)";

          "${super}+h" = "focus left";
          "${super}+j" = "focus down";
          "${super}+k" = "focus up";
          "${super}+l" = "focus right";

          "${super}+Shift+h" = "move left";
          "${super}+Shift+j" = "move down";
          "${super}+Shift+k" = "move up";
          "${super}+Shift+l" = "move right";

          "${super}+Ctrl+Shift+h" = "move workspace to output left";
          "${super}+Ctrl+Shift+j" = "move workspace to output down";
          "${super}+Ctrl+Shift+k" = "move workspace to output up";
          "${super}+Ctrl+Shift+l" = "move workspace to output right";

          "${super}+Left" = "workspace prev";
          "${super}+Right" = "workspace next";
          "${super}+bracketleft" = "workspace prev";
          "${super}+bracketright" = "workspace next";

          "${super}+Ctrl+Left" = "workspace prev_on_output";
          "${super}+Ctrl+Right" = "workspace next_on_output";
          "${super}+Ctrl+bracketleft" = "workspace prev_on_output";
          "${super}+Ctrl+bracketright" = "workspace next_on_output";

          "${super}+Tab" = "workspace back_and_forth";

          # Carry window to workspace 1-10
          "${super}+${alt}+1" =
            "move container to workspace number 1; workspace number 1";
          "${super}+${alt}+2" =
            "move container to workspace number 2; workspace number 2";
          "${super}+${alt}+3" =
            "move container to workspace number 3; workspace number 3";
          "${super}+${alt}+4" =
            "move container to workspace number 4; workspace number 4";
          "${super}+${alt}+5" =
            "move container to workspace number 5; workspace number 5";
          "${super}+${alt}+6" =
            "move container to workspace number 6; workspace number 6";
          "${super}+${alt}+7" =
            "move container to workspace number 7; workspace number 7";
          "${super}+${alt}+8" =
            "move container to workspace number 8; workspace number 8";
          "${super}+${alt}+9" =
            "move container to workspace number 9; workspace number 9";
          "${super}+${alt}+0" =
            "move container to workspace number 10; workspace number 10;";

          "${super}+Shift+grave" = "move scratchpad";
          "${super}+grave" = "scratchpad show";

          # Carry window to next free workspace
          # "${mod}+grave" = "i3-next-workspace"; # TODO create package for https://github.com/regolith-linux/i3-next-workspace/blob/main/i3-next-workspace

          "${super}+Shift+r" = "refresh";
          "${super}+Shift+c" = "reload";

          "${super}+r" = "mode resize";

          "${super}+v" = "split vertical";
          "${super}+g" = "split horizontal";
          "${super}+BackSpace" = "split toggle";

          "${super}+f" = "fullscreen toggle";
          "${super}+Shift+f" = "floating toggle";
          "${super}+t" = "focus mode_toggle";
          "${super}+Shift+t" = "layout toggle tabbed splith splitv";

          "${super}+Control+e" = ''[class="Emacs"] focus'';
          "${super}+Control+s" = ''[class="Slack"] focus'';
          "${super}+Control+d" = ''[title="Linear"] focus'';
          "${super}+Control+f" = ''[class="kitty"] focus'';
          "${super}+Control+g" = ''[class="Chromium"] focus'';
        };
      keycodebindings = {
        # "214" = "exec /bin/script.sh";
      };
      modes = {
        resize = resizeKeybinds {
          narrower = "h";
          taller = "j";
          shorter = "k";
          wider = "l";
        } // quitModeKeybinds;
      };
      bars = [ ];
      fonts = {
        names =
          [ "FontAwesome" "FontAwesome5Free" "Fira Sans" "DejaVu Sans Mono" ];
        size = 10.0;
      };
      focus = {
        followMouse = false;
        forceWrapping = false;
        mouseWarping = true;
        newWindow = "smart";
      };
      gaps = {
        horizontal = 5;
        vertical = 5;
        inner = 5;
        outer = 5;
        left = 5;
        right = 5;
        top = 5;
        bottom = 5;
        smartBorders = "no_gaps";
        smartGaps = true;
      };
      floating = {
        modifier = keysyms.super; # for dragging floating windows
        criteria = [
          { class = "blueman-manager"; }
          { class = "nm-connection-editor"; }
          { class = "obs"; }
          { class = "syncthingtray"; }
          { class = "thunar"; }
          { class = "System76 Keyboard Configurator"; }
          { class = "pavucontrol"; }
          { title = "Artha"; }
          { title = "Calculator"; }
          { title = "Steam.*"; }
          { title = "doom-capture"; }
          { window_role = "pop-up"; }
          { window_role = "prefwindow"; }
        ];
      };
      defaultWorkspace = "workspace number 1";
      workspaceLayout = "default";
      workspaceAutoBackAndForth = false;
      assigns = {
        "1" = [ ];
        "2" = [ ];
        "3" = [ ];
        "4: Linear" = [{ title = "Linear"; }];
        "5" = [ ];
        "6" = [ ];
        "7" = [ ];
        "8: Email" = [{ class = "Geary"; }];
        "9: Chat" = [{ class = "Slack"; }];
        "0" = [ ];
      };
      startup = [
        {
          command = "${getExe pkgs.feh} --bg-scale ${./background.jpg}";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar";
          always = true;
          notification = false;
        }
      ];
    };
  };

  services.network-manager-applet.enable = true;

  # needs ./tray.nix
  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      package = pkgs.syncthingtray;
    };
  };

  services.clipmenu = {
    enable = true;
    launcher = bins.rofi;
  };

  xdg.enable = true;

  home.username = "logan";
  home.homeDirectory = "/home/logan";

  home.packages = with pkgs; [
    ark
    jetbrains.idea-community
    obsidian
    slack
    trash-cli
    vlc
    i3-gaps
    xorg.xev
    xorg.xprop
    xorg.xkill
  ];

  home.stateVersion = "22.11";
}
