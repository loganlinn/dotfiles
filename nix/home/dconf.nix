# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "com/github/Ory0n/Resource_Monitor" = {
      cpufrequencystatus = false;
      cpustatus = true;
      decimalsstatus = false;
      diskdeviceslist = ["/dev/nvme0n1p3 / false true" "/dev/nvme0n1p1 /boot/efi false false" "/dev/sda2 /media/logan/restic-repo false false" "/dev/sda1 /media/logan/Framework false false"];
      diskspacemonitor = "free";
      diskspaceunit = "numeric";
      diskspacewidth = 0;
      diskstatsmode = "single";
      diskstatsstatus = false;
      diskstatswidth = 0;
      iconsposition = "left";
      iconsstatus = true;
      leftclickstatus = "gnome-system-monitor";
      netautohidestatus = false;
      netethstatus = false;
      netwlanstatus = false;
      rammonitor = "used";
      refreshtime = 3;
      swapstatus = false;
      thermalcputemperaturedeviceslist = ["acpitz: temp1-false-/sys/class/hwmon/hwmon1/temp1_input" "nvme: Composite-false-/sys/class/hwmon/hwmon3/temp1_input" "nvme: Sensor 1-false-/sys/class/hwmon/hwmon3/temp2_input" "nvme: Sensor 2-false-/sys/class/hwmon/hwmon3/temp3_input" "iwlwifi_1: temp1-false-/sys/class/hwmon/hwmon4/temp1_input" "coretemp: Package id 0-true-/sys/class/hwmon/hwmon5/temp1_input" "coretemp: Core 0-false-/sys/class/hwmon/hwmon5/temp2_input" "coretemp: Core 1-false-/sys/class/hwmon/hwmon5/temp3_input" "coretemp: Core 2-false-/sys/class/hwmon/hwmon5/temp4_input" "coretemp: Core 3-false-/sys/class/hwmon/hwmon5/temp5_input"];
      thermalcputemperaturestatus = true;
      thermalcputemperaturewidth = 0;
    };

    "org/gnome/Weather" = {
      locations = "[<(uint32 2, <('San Francisco', 'KOAK', true, [(0.65832848982162007, -2.133408063190589)], [(0.659296885757089, -2.1366218601153339)])>)>]";
    };

    "org/gnome/desktop/a11y/applications" = {
      screen-reader-enabled = false;
    };

    "org/gnome/desktop/privacy" = {
      report-technical-problems = false;
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Alt>F4" "<Shift><Super>q"];
      lower = ["<Super>z"];
      move-to-workspace-1 = ["<Super><Shift>1"];
      move-to-workspace-10 = ["<Super><Shift>0"];
      move-to-workspace-2 = ["<Super><Shift>2"];
      move-to-workspace-3 = ["<Super><Shift>3"];
      move-to-workspace-4 = ["<Super><Shift>4"];
      move-to-workspace-5 = ["<Super><Shift>5"];
      move-to-workspace-6 = ["<Super><Shift>6"];
      move-to-workspace-7 = ["<Super><Shift>7"];
      move-to-workspace-8 = ["<Super><Shift>8"];
      move-to-workspace-9 = ["<Super><Shift>9"];
      move-to-workspace-down = ["<Shift><Super>braceright"];
      move-to-workspace-up = ["<Shift><Super>braceleft"];
      panel-run-dialog = ["<Alt>F2" "<Primary><Super>space"];
      switch-input-source = [];
      switch-input-source-backward = [];
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-10 = ["<Super>0"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      switch-to-workspace-5 = ["<Super>5"];
      switch-to-workspace-6 = ["<Super>6"];
      switch-to-workspace-7 = ["<Super>7"];
      switch-to-workspace-8 = ["<Super>8"];
      switch-to-workspace-9 = ["<Super>9"];
      switch-to-workspace-down = ["<Primary><Super>Down" "<Primary><Super>KP_Down" "<Super>bracketright"];
      switch-to-workspace-up = ["<Primary><Super>Up" "<Primary><Super>KP_Up" "<Primary><Super>k" "<Super>bracketleft"];
      toggle-on-all-workspaces = ["<Super>u"];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      control-center = ["<Shift><Super>less"];
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"];
      email = [];
      home = ["<Shift><Super>n"];
      mic-mute = ["<Super>F10"];
      stop = ["<Super>F9"];
      terminal = ["<Super>t" "<Super>Return"];
      www = ["<Shift><Super>Return"];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>e";
      command = "emacs";
      name = "Emacs";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>d";
      command = "gnome-control-center display";
      name = "Display Settings";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>s";
      command = "gnome-control-center-menu";
      name = "Settings";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Primary><Alt>e";
      command = "emote";
      name = "Emote";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      binding = "<Primary><Super>e";
      command = "doom +everywhere";
      name = "Emacs Everywhere";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled = false;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      extend-height = false;
      manualhide = true;
    };

    "org/gnome/shell/extensions/pop-cosmic" = {
      clock-alignment = "CENTER";
      show-applications-button = false;
      show-workspaces-button = true;
    };

    "org/gnome/shell/extensions/pop-shell" = {
      activate-launcher = ["<Super>slash" "<Super>space"];
      active-hint = true;
      gap-inner = mkUint32 1;
      gap-outer = mkUint32 1;
      hint-color-rgba = "rgba(153,108,251,0.702703)";
      pop-monitor-left = ["<Shift><Super>Left" "<Shift><Super>KP_Left"];
      pop-monitor-right = ["<Shift><Super>Right" "<Shift><Super>KP_Right"];
      pop-workspace-down = ["<Shift><Super>Down" "<Shift><Super>KP_Down"];
      pop-workspace-up = ["<Shift><Super>Up" "<Shift><Super>KP_Up"];
      show-title = false;
      tile-by-default = true;
      tile-enter = ["<Super>r"];
      tile-move-down-global = ["<Shift><Super>j"];
      tile-move-left-global = ["<Shift><Super>h"];
      tile-move-right-global = ["<Shift><Super>l"];
      tile-move-up-global = ["<Shift><Super>k"];
      toggle-stacking-global = [];
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Nordic-v40";
    };

    "org/gnome/shell/keybindings" = {
      open-application-menu = ["<Super>c"];
      toggle-overview = ["<Shift><Super>space" "<Alt><Super>Up"];
    };

    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = "[<(uint32 2, <('San Francisco', 'KOAK', true, [(0.65832848982162007, -2.133408063190589)], [(0.659296885757089, -2.1366218601153339)])>)>]";
    };

    "org/gnome/system/location" = {
      enabled = false;
    };
  };
}
