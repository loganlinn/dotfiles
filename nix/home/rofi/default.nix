{ config
, lib
, pkgs
, ...
}:

with lib;

let

  inherit (lib.my) nerdfonts;

  modeDisplay = label: icon: "${icon} ${label}";

in
{
  home.packages = with pkgs; [
    # wrappers (not plugins)
    rofi-systemd
    rofi-pulse-select
    (writeShellScriptBin "rofi-power" ''
      ${getExe config.programs.rofi.finalPackage} \
        -show power \
        -modi "power:${getExe rofi-power-menu}" \
        -config "${./power-menu.rasi}"
    '')
  ];

  programs.rofi = {
    enable = true;
    cycle = true;
    pass.enable = config.programs.password-store.enable;
    pass.stores = [ config.programs.password-store.settings.PASSWORD_STORE_DIR ];
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      rofi-file-browser
      rofi-top
    ];
    terminal = getExe config.programs.kitty.package;
    font = "Iosevka Nerd Font 12";
    extraConfig = {
      modes = [ "combi" "emoji" "ssh" "keys" ]; # default modes
      modi = [
        "combi"
        "drun"
        "window"
        "run"
        "emoji"
        "calc"
        "ssh"
        "keys"
        "file-browser-extended"
      ];
      monitor = -4; # monitor with focused window (default=-5. monitor where cursor is)
      show-icons = true;
      markup = true;
      case-sensitive = false;
      sort = true;
      sorting-method = "fzf";
      scroll-method = 0; # 0: Page, 1: Centered
      window-format = "{w}    {c}   {t}"; # w (desktop name), t (title), n (name), r (role), c (class)
      combi-hide-mode-prefix = true;
      combi-modes = [ "drun" "window" "power" ];
      combi-display-format = "{mode}  {text}"; # uses tab for styling with tab-stops
      display-combi = modeDisplay "combi" nerdfonts.md.apps;
      display-drun = modeDisplay "drun" nerdfonts.md.application;
      display-run = modeDisplay "run" nerdfonts.md.console_line;
      display-emoji = modeDisplay "emoji" nerdfonts.md.sticker_emoji;
      display-calc = modeDisplay "calc" nerdfonts.md.calculator;
      display-file-browser-extended = modeDisplay "file" nerdfonts.md.file_find;
      display-power = modeDisplay "power" nerdfonts.md.power;
      display-window = modeDisplay "window" nerdfonts.md.window_open;
      display-windowcd = modeDisplay "windowcd" nerdfonts.md.window_open_variant;
      display-keys = modeDisplay "keys" nerdfonts.md.keyboard;
      display-ssh = modeDisplay "ssh" nerdfonts.md.console_network;
      display-top = modeDisplay "top" nerdfonts.md.application_cog;
      ssh-command = "kitty --hold -- kitten ssh {host} [-p {port}]";
      steal-focus = false;
      click-to-exit = true;
      parse-hosts = true;
      parse-known-hosts = true;
      drun-categories = "";
      drun-match-fields = "all";
      drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
      drun-show-actions = true; # expose any additional actions (like opening incoginto window with google-chrome.desktop)
      drun-url-launcher = "xdg-open";
      run-shell-command = "kitty --hold {cmd}";
      kb-move-front = "Control+a";
      kb-move-end = "Control+e";
      kb-move-word-back = "Alt+b";
      kb-move-word-forward = [ "Alt+f" "Control+Right" ];
      kb-move-char-back = [ "Left" "Control+b" ];
      kb-move-char-forward = [ "Right" "Control+f" ];
      kb-remove-word-back = [ "Control+Alt+h" "Control+BackSpace" ];
      kb-remove-word-forward = "Control+Alt+d";
      kb-remove-char-forward = [ "Delete" "Control+d" ];
      kb-remove-char-back = [ "BackSpace" "Shift+BackSpace" ];
      kb-remove-to-eol = "Control+Shift+e";
      kb-remove-to-sol = "Control+Shift+a";
      kb-accept-entry = [ "Control+m" "Return" "KP_Enter" ];
      kb-accept-custom = "Control+Return";
      kb-accept-custom-alt = "Control+Shift+Return";
      kb-accept-alt = "Shift+Return";
      kb-delete-entry = "Shift+Delete";
      kb-row-left = "Control+Page_Up";
      kb-row-right = "Control+Page_Down";
      kb-row-up = [ "Up" "Control+k" "Shift+Tab" "Shift+ISO_Left_Tab" ];
      kb-row-down = [ "Down" "Control+j" ];
      kb-clear-line = "Control+u";
      kb-mode-next = [ "Shift+Right" "Control+Tab" "Control+l" ];
      kb-mode-previous = [ "Shift+Left" "Control_L+ISO_Left_Tab" "Control+h" ]; # ISO_Left_Tab = Shift+Tab
      kb-mode-complete = "Control+t";
      kb-primary-paste = [ "Control+V" "Control+Shift+V" ];
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
      kb-cancel = "Escape,Control+g";
    };
    configPath = "${config.xdg.configHome}/rofi/common.rasi";
  };

  xdg.configFile = {
    "rofi/config.rasi".text = ''
      @import "${config.programs.rofi.configPath}"
      @import "shared.rasi"
    '';
    "rofi/colors.rasi".text = import ./colors.nix config.colorScheme;
    "rofi/theme.rasi".source = ./theme.rasi;
    "rofi/shared.rasi".text = ''
      @import "colors.rasi"
      @import "theme.rasi"
    '';
    "rofi/scripts/power.sh".source = getExe pkgs.rofi-power-menu;
  } // lib.my.files.sourceSet {
    dir = ./scripts;
    prefix = "rofi/scripts/";
  } // lib.my.files.sourceSet {
    dir = ./libexec;
    prefix = "rofi/libexec/";
  };

  home.sessionVariables.ROFI_SYSTEMD_TERM = config.programs.rofi.terminal;
}
