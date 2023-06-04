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
      rofi-power-menu
    ];

    extraConfig = {
      modi = "drun,run,window,ssh,calc,emoji";
      show-icons = true;
      markup = true;
      display-drun = " Apps";
      display-run = " Run";
      display-file-browser-extended = " Files";
      display-window = " Windows";
      display-ssh = " SSH";
      case-sensitive = false;
      steal-focus = false;
      click-to-exit = true;
      parse-hosts = true;
      parse-known-hosts = true;
      drun-categories = "";
      drun-match-fields = "all";
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
      kb-mode-previous = "Shift+Left,Control+Shift+Tab,Control+h";
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
      kb-cancel = "Escape,Control+g,Control+bracketleft";
    };
  };

  home.packages = with pkgs; [
    rofi-systemd # standalone launcher, rather than a plugin
  ];

  home.sessionVariables.ROFI_SYSTEMD_TERM="kitty"; # defaults to urxvt
}
