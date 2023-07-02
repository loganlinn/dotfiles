{ config
, options
, lib
, pkgs
, ...
}:
with lib; {
  programs.rofi = {
    enable = true;

    cycle = true;

    pass = optionalAttrs config.programs.password-store.enable {
      enable = true;
      stores = [ config.programs.password-store.settings.PASSWORD_STORE_DIR ];
    };

    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      rofi-file-browser
      rofi-bluetooth
      rofi-pulse-select
    ];

    terminal = getExe config.programs.kitty.package;

    font = "Iosevka Nerd Font 12";

    extraConfig = {
      modes = "combi,emoji,ssh,keys";
      modi = "combi,drun,window,run,emoji,calc,ssh,keys,file-browser-extended";
      combi-hide-mode-prefix = true;
      combi-modes = "drun,window";
      # location = 6; # bottom center
      location = 0; # center
      show-icons = true;
      markup = true;
      case-sensitive = false;
      sort = true;
      sorting-method = "fzf";
      combi-display-format = "{text}  {mode}"; # <-- tab!
      display-combi = "󱃵 program";
      display-drun = "󰀻 app";
      display-run = "󰆍  run";
      display-emoji = "󰦥 emoji";
      display-calc = "󰃬 calc";
      display-filebrowser = "󰈞 file";
      display-file-browser-extended = "󰈞 file";
      display-window = "󰖲 window";
      display-windowcd = "󱇜 windowcd";
      display-keys = "󰌌 keys";
      display-ssh = "󰢩 ssh";
      ssh-command = "kitty --hold -- kitten ssh {host} [-p {port}]";
      steal-focus = false;
      click-to-exit = true;
      parse-hosts = true;
      parse-known-hosts = true;
      drun-categories = "";
      drun-match-fields = "all";
      drun-show-actions = true; # expose any additional actions (like opening incoginto window with google-chrome.desktop)
      kb-move-front = "Control+a";
      kb-move-end = "Control+e";
      kb-move-word-back = "Alt+b";
      kb-move-word-forward = "Alt+f,Control+Right";
      kb-move-char-back = "Left,Control+b";
      kb-move-char-forward = "Right,Control+f";
      kb-remove-word-back = "Control+Alt+h,Control+BackSpace";
      kb-remove-word-forward = "Control+Alt+d";
      kb-remove-char-forward = "Delete,Control+d";
      kb-remove-char-back = "BackSpace,Shift+BackSpace";
      kb-remove-to-eol = "Control+Shift+e";
      kb-remove-to-sol = "Control+Shift+a";
      kb-accept-entry = "Control+m,Return,KP_Enter";
      kb-accept-custom = "Control+Return";
      kb-accept-custom-alt = "Control+Shift+Return";
      kb-accept-alt = "Shift+Return";
      kb-delete-entry = "Shift+Delete";
      kb-row-left = "Control+Page_Up";
      kb-row-right = "Control+Page_Down";
      kb-row-up = "Up,Control+k,Shift+Tab,Shift+ISO_Left_Tab";
      kb-row-down = "Down,Control+j";
      kb-clear-line = "Control+u";
      kb-mode-next = "Shift+Right,Control+Tab,Control+l";
      kb-mode-previous = "Shift+Left,Control_L+ISO_Left_Tab,Control+h"; # ISO_Left_Tab = Shift+Tab
      kb-mode-complete = "Control+t";
      kb-primary-paste = "Control+V,Control+Shift+V";
      ml-row-left = "ScrollLeft";
      ml-row-right = "ScrollRight";
      ml-row-up = "ScrollUp";
      ml-row-down = "ScrollDown";
      me-select-entry = "MousePrimary";
      me-accept-entry = "MouseDPrimary";
      me-accept-custom = "Control+MouseDPrimary";
      kb-ellipsize = "Alt+period";
      kb-toggle-case-sensitivity = "grave,dead_grave";
      kb-toggle-sort = "Alt+grave";
      kb-cancel = "Escape,Control+g,Control+c,Control+w";
    };

    configPath = "${config.xdg.configHome}/rofi/core.rasi";
  };

  # xdg.configFile."rofi/colors/current.rasi".text = with config.colorScheme.colors; ''
  xdg.configFile."rofi/config.rasi".text = with config.colorScheme.colors; ''
    @import "${config.programs.rofi.configPath}"

    * {
        background:                  #${base00};
        background2:                 #${base01};
        selected-background:         #${base02};
        border-color:                #${base03};
        foreground2:                 #${base04};
        foreground:                  #${base05};
        lightfg:                     #${base06};
        lightbg:                     #${base07};
        red:                         #${base08};
        magenta:                     #${base09};
        linkfg:                      #${base0A};
        green:                       #${base0B};
        cyan:                        #${base0C};
        lightfg:                     #${base06};
        lightbg:                     #${base07};
        separatorcolor:              #${base04};
        selected-foreground:         #${base00};
        activebg:                    #${base03};
        activefg:                    #${base05};
        normal-foreground:           @foreground;
        normal-background:           @background;
        active-foreground:           @activefg;
        active-background:           @activebg;
        urgent-foreground:           @foreground;
        urgent-background:           @red;
        alternate-normal-foreground: @foreground;
        alternate-normal-background: @background2;
        alternate-active-foreground: @activefg;
        alternate-active-background: @activebg;
        alternate-urgent-foreground: @background;
        alternate-urgent-background: @magenta;
        selected-normal-foreground:  @selected-foreground;
        selected-normal-background:  @selected-background;
        selected-active-foreground:  @selected-foreground;
        selected-active-background:  @selected-background;
        selected-urgent-foreground:  @background;
        selected-urgent-background:  @red;
    }

    window {
      width: 640px;
      padding: 5px;
    }

    inputbar {
      spacing: 8px;
      padding: 8px;
    }

    prompt, entry, element-icon, element-text {
      vertical-align: 0.5;
    }

    textbox {
      padding: 8px;
    }

    listview {
      spacing: 5px;
      lines: 8;
      columns: 1;
      fixed-height: false;
    }

    element {
      padding: 8px;
      spacing: 8px;
    }

    element-icon {
      size:   0.8em;
    }

    element-text {
      text-color: inherit;
    }
    '';

  home.packages = with pkgs; [
    rofi-systemd # standalone launcher, rather than a plugin
    (writeShellScriptBin "rofi-power" ''
      ${getExe config.programs.rofi.finalPackage} -show Power -modes "Power:${getExe pkgs.rofi-power-menu}"
    '')
  ];

  # home.sessionVariables.ROFI_SYSTEMD_TERM = config.programs.rofi.terminal;
}
