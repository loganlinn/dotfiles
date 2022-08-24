# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {

    "org/gnome/desktop/input-sources" = {
      per-window = false;
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "caps:ctrl_modifier" ];
    };

    # "org/gnome/desktop/interface" = {
    #   clock-show-weekday = true;
    #   gtk-enable-primary-paste = false;
    #   gtk-im-module = "gtk-im-context-simple";
    #   gtk-theme = "Nordic-darker-v40";
    # };

    "org/gnome/desktop/notifications" = {
      application-children = [
        "io-elementary-appcenter"
        "gnome-printers-panel"
        "gnome-power-panel"
        "org-pop-os-transition"
        "org-gnome-nautilus"
        "slack"
        "firefox"
        "vino-server"
        "google-chrome"
      ];
      show-in-lock-screen = true;
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-printers-panel" = {
      application-id = "gnome-printers-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/google-chrome" = {
      application-id = "google-chrome.desktop";
    };

    "org/gnome/desktop/notifications/application/io-elementary-appcenter" = {
      application-id = "io.elementary.appcenter.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-pop-os-transition" = {
      application-id = "org.pop_os.transition.desktop";
    };

    "org/gnome/desktop/notifications/application/slack" = {
      application-id = "slack.desktop";
    };

    "org/gnome/desktop/notifications/application/vino-server" = {
      application-id = "vino-server.desktop";
    };

    "org/gnome/desktop/wm/keybindings" = {
      begin-move = [];
      close = [ "<Shift><Super>q" ];
      move-to-workspace-1 = [ "<Super><Shift>1" ];
      move-to-workspace-10 = [ "<Super><Shift>0" ];
      move-to-workspace-2 = [ "<Super><Shift>2" ];
      move-to-workspace-3 = [ "<Super><Shift>3" ];
      move-to-workspace-4 = [ "<Super><Shift>4" ];
      move-to-workspace-5 = [ "<Super><Shift>5" ];
      move-to-workspace-6 = [ "<Super><Shift>6" ];
      move-to-workspace-7 = [ "<Super><Shift>7" ];
      move-to-workspace-8 = [ "<Super><Shift>8" ];
      move-to-workspace-9 = [ "<Super><Shift>9" ];
      switch-input-source = [];
      switch-input-source-backward = [];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-10 = [ "<Super>0" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      switch-to-workspace-7 = [ "<Super>7" ];
      switch-to-workspace-8 = [ "<Super>8" ];
      switch-to-workspace-9 = [ "<Super>9" ];
      toggle-on-all-workspaces = [ "<Super>b" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 9;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      experimental-features = [];
      overlay-key = "Super_R";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      search-filter-time-type = "last_modified";
      search-view = "list-view";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      calculator = [ "<Super>equal" ];
      control-center = [ "<Shift><Super>F2" ];
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
      email = [ "<Primary><Super>e" ];
      home = [ "<Shift><Super>n" ];
      terminal = [ "<Super>Return" ];
      www = [ "<Shift><Super>Return" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>e";
      command = "emacs";
      name = "Launch Emacs";
    };

    # "org/gnome/shell" = {
    #   enabled-extensions = [
    #     "alt-tab-raise-first-window@system76.com" 
    #     "always-show-workspaces@system76.com" 
    #     "ding@rastersoft.com"
    #     "pop-shell@system76.com"
    #     "pop-shop-details@system76.com"
    #     "system76-power@system76.com"
    #     "ubuntu-appindicators@ubuntu.com"
    #     "improved-workspace-indicator@michaelaquilina.github.io"
    #     "instantworkspaceswitcher@amalantony.net"
    #   ];
    # };

    "org/gnome/shell/extensions/improved-workspace-indicator" = {
      panel-position = "left";
    };

    "org/gnome/shell/extensions/pop-shell" = {
      activate-launcher = [ "<Super>slash" "<Super>space" ];
      active-hint = true;
      gap-inner = mkUint32 1;
      gap-outer = mkUint32 1;
      hint-color-rgba = "rgba(226,108,251,0.72)";
      show-skip-taskbar = true;
      show-title = true;
      smart-gaps = false;
      tile-by-default = true;
      tile-enter = [ "<Super>KP_Enter" "<Super>r" ];
    };

    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];
      switch-to-application-7 = [];
      switch-to-application-8 = [];
      switch-to-application-9 = [];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = true;
      show-size-column = true;
      show-type-column = true;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
    };
  };
}
