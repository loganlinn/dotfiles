{ config, lib, pkgs, ... }: {
  imports = [
    ./_1password.nix
    ./3d-graphics.nix
    ./browser.nix
    ./common.nix
    ./dev.nix
    ./emacs.nix
    ./fonts.nix
    ./gh.nix
    ./git.nix
    ./graphical.nix
    ./kitty
    ./neovim.nix
    ./pretty.nix
    ./rofi.nix
    ./sync.nix
    ./vpn.nix
    ./vscode.nix
    ./xdg.nix
    ./zsh.nix
  ];

  programs.librewolf.enable = true;

  services.syncthing.tray = {
    enable = true;
    package = pkgs.syncthingtray;
  };

  programs.rofi.enable = true;
  programs.nnn.enable = true;

  xsession.enable = true;
  xsession.windowManager.i3 = let
    terminal = lib.getExe config.programs.kitty.package;
    browser = lib.getExe config.programs.google-chrome.package;
    editor = "emacs";
    fileManager =
      "${terminal} ${config.programs.nnn.finalPackage}/bin/nnn -a -P -p";
    rofi = lib.getExe config.programs.rofi.package;
    rofiModi = mode: "${rofi} -show ${mode}"; # TODO: -theme ${rofiTheme}
    menu = rofiModi "drun";
    alt = "Mod1";
    mod = "Mod4";
    directions = {
      left = [ "Left" "h" ];
      down = [ "Down" "j" ];
      up = [ "Up" "k" ];
      right = [ "Right" "h" ];
    };
  in {
    enable = true;
    package = pkgs.i3-gaps;

    config = {
      inherit terminal menu;

      modifier = mod;

      # bars = [];

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

      # assigns = ...;

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

      keybindings = let mkExec = cmd: "exec ${cmd}";
      in lib.mkOptionDefault {
        "${mod}+Shift+Return" = mkExec browser;
        "${mod}+Shift+n" = mkExec fileManager;
        "${mod}+e" = mkExec editor;
        "${mod}+q" = ''[con_id="__focused__"] kill'';
        "${mod}+${alt}+q" = ''
          [con_id="__focused__"] exec --no-startup-id kill -9 $(${pkgs.xdotool}/bin/xdotool getwindowfocus getwindowpid)'';

        "${mod}+space" = mkExec menu;
        "${mod}+Shift+space" = mkExec (rofiModi "run");
        "${mod}+Ctrl+space" = mkExec (rofiModi "window");

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+Ctrl+Shift+h" = "move workspace to output left";
        "${mod}+Ctrl+Shift+j" = "move workspace to output down";
        "${mod}+Ctrl+Shift+k" = "move workspace to output up";
        "${mod}+Ctrl+Shift+l" = "move workspace to output right";

        "${mod}+Tab" = "workspace back_and_forth";

        "${mod}+Left" = "workspace prev";
        "${mod}+Right" = "workspace next";
        "${mod}+bracketleft" = "workspace prev";
        "${mod}+bracketright" = "workspace next";

        "${mod}+Ctrl+Left" = "workspace prev_on_output";
        "${mod}+Ctrl+Right" = "workspace next_on_output";
        "${mod}+Ctrl+bracketleft" = "workspace prev_on_output";
        "${mod}+Ctrl+bracketright" = "workspace next_on_output";

        # Carry window to next free workspace
        # "${mod}+grave" = "i3-next-workspace"; # TODO create package for https://github.com/regolith-linux/i3-next-workspace/blob/main/i3-next-workspace

        # Carry window to workspace 1-10
        "${mod}+${alt}+1" =
          "move container to workspace number 1; workspace number 1";
        "${mod}+${alt}+2" =
          "move container to workspace number 2; workspace number 2";
        "${mod}+${alt}+3" =
          "move container to workspace number 3; workspace number 3";
        "${mod}+${alt}+4" =
          "move container to workspace number 4; workspace number 4";
        "${mod}+${alt}+5" =
          "move container to workspace number 5; workspace number 5";
        "${mod}+${alt}+6" =
          "move container to workspace number 6; workspace number 6";
        "${mod}+${alt}+7" =
          "move container to workspace number 7; workspace number 7";
        "${mod}+${alt}+8" =
          "move container to workspace number 8; workspace number 8";
        "${mod}+${alt}+9" =
          "move container to workspace number 9; workspace number 9";
        "${mod}+${alt}+0" =
          "move container to workspace number 10; workspace number 10;";

        "${mod}+Shift+r" = "refresh";
        "${mod}+Shift+c" = "reload";

        "${mod}+r" = "mode resize";

        "${mod}+v" = "split vertical";
        "${mod}+g" = "split horizontal";
        "${mod}+BackSpace" = "split toggle";

        "${mod}+f" = "fullscreen toggle";
        "${mod}+Shift+f" = "floating toggle";
      };

      modes = {
        resize = {
          "Left" = "resize shrink width 8 px or 8 ppt";
          "Down" = "resize grow height 8 px or 8 ppt";
          "Up" = "resize shrink height 8 px or 8 ppt";
          "Right" = "resize grow width 8 px or 8 ppt";

          "Shift+Left" = "resize shrink width 16 px or 16 ppt";
          "Shift+Down" = "resize grow height 16 px or 16 ppt";
          "Shift+Up" = "resize shrink height 16 px or 16 ppt";
          "Shift+Right" = "resize grow width 16 px or 16 ppt";

          "h" = "resize shrink width 8 px or 8 ppt";
          "j" = "resize grow height 8 px or 8 ppt";
          "k" = "resize shrink height 8 px or 8 ppt";
          "l" = "resize grow width 8 px or 8 ppt";

          "Shift+h" = "resize shrink width 16 px or 16 ppt";
          "Shift+j" = "resize grow height 16 px or 16 ppt";
          "Shift+k" = "resize shrink height 16 px or 16 ppt";
          "Shift+l" = "resize grow width 16 px or 16 ppt";

          "${mod}+r" = "mode default";
          "Return" = "mode default";
          "Escape" = "mode default";
          "Ctrl+c" = "mode default";
          "Ctrl+g" = "mode default";
        };
      };

      floating = {
        # Use Mouse+$mod to drag floating windows to their wanted position
        modifier = mod;
      };

      defaultWorkspace = "workspace number 1";
      workspaceLayout = lib.mkOptionDefault "default";
      workspaceAutoBackAndForth = true;

      #     startup = [
      #       {
      #         command = ''
      #           ${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY;\
      #           ${pkgs.systemd}/bin/systemctl --user start i3-session.target
      #         '';
      #         always = false;
      #         notification = false;
      #       }
      #       {
      #         command = ''
      #           ${pkgs.systemd}/bin/systemctl --user restart polybar
      #         '';
      #         always = true;
      #         notification = false;
      #       }
      #     ];
    };
    extraConfig = ''
      ## Plasma
      for_window [title="Desktop — Plasma"] kill, floating enable, border none
      for_window [class="plasmashell"] floating enable
      for_window [class="Plasma"] floating enable, border none
      for_window [title="plasma-desktop"] floating enable, border none
      for_window [title="win7"] floating enable, border none
      for_window [class="krunner"] floating enable, border none
      for_window [class="Kmix"] floating enable, border none
      for_window [class="Klipper"] floating enable, border none
      for_window [class="Plasmoidviewer"] floating enable, border none
      for_window [class="(?i)*nextcloud*"] floating disable
      for_window [class="plasmashell" window_type="notification"] floating enable, border none, move right 700px, move down 450px
      no_focus [class="plasmashell" window_type="notification"]
    '';
  };

  services.polybar = {
    enable = false;
    package = pkgs.polybar.override {
      i3GapsSupport = true;
      alsaSupport = true;
      pulseSupport = true;
      iwSupport = true;
      githubSupport = true;
    };
    script = ''
      for m in $(polybar --list-monitors | ${pkgs.coreutils-full}/bin/cut -d":" -f1); do
          MONITOR=$m polybar --reload top &
      done
    '';
  };

  services.network-manager-applet.enable = true;

  # home.sessionVariables = { KDEWM = "${pkgs.i3-gaps}/bin/i3"; };

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
