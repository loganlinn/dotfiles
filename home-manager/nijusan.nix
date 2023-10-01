{ self', config, pkgs, lib, nix-colors, ... }:

let inherit (nix-colors.lib.contrib { inherit pkgs; }) nixWallpaperFromScheme;

in {
  imports = [
    ../nix/home/awesomewm.nix
    ../nix/home/common.nix
    ../nix/home/conky
    ../nix/home/davfs2.nix
    ../nix/home/deadd
    ../nix/home/dev # TODO module
    ../nix/home/dunst
    ../nix/home/emacs
    ../nix/home/eww
    ../nix/home/git/graphite.nix
    ../nix/home/home-manager.nix
    ../nix/home/hexchat.nix
    ../nix/home/intellij.nix
    ../nix/home/kakoune.nix
    ../nix/home/kitty
    # ../nix/home/lnav
    ../nix/home/mpd.nix
    ../nix/home/mpv.nix
    ../nix/home/nnn.nix
    ../nix/home/pretty.nix
    ../nix/home/qalculate
    ../nix/home/ssh.nix
    ../nix/home/syncthing.nix
    ../nix/home/urxvt.nix
    ../nix/home/vpn.nix
    ../nix/home/vscode.nix
    ../nix/home/x11.nix
    ../nix/home/yt-dlp.nix
    ../nix/home/yubikey.nix
    ../nix/modules/services
    ../nix/modules/spellcheck.nix
    ../nix/modules/desktop
    ../nix/modules/desktop/browsers
    ../nix/modules/desktop/browsers/firefox.nix
    ../nix/modules/desktop/i3
  ];

  colorScheme = nix-colors.colorSchemes.doom-one; # nix-colors

  my.deadd.enable = true;
  my.awesomewm.enable = true;
  my.programs.eww.enable = true;
  my.java.jvms = { inherit (pkgs) jdk11; };
  modules.polybar.networks = [
    {
      interface = "eno3";
      interface-type = "wired";
    }
    {
      interface = "wlo1";
      interface-type = "wireless";
    }
  ];
  modules.spellcheck.enable = true;
  modules.theme.active = "arc";
  modules.theme.wallpaper = nixWallpaperFromScheme {
    scheme = config.colorscheme;
    width = 3840;
    height = 1600;
    logoScale = 4.0;
  };
  modules.desktop.browsers = {
    default = "${
        lib.getExe config.programs.google-chrome.package
      } '--profile-directory=Profile 1'"; # work
    alternate = "${
        lib.getExe config.programs.google-chrome.package
      } '--profile-directory=Default'"; # personal
  };

  programs.kitty.enable = true;
  programs.wezterm.enable = false;
  programs.emacs.enable = true;
  programs.rofi.enable = true;
  programs.google-chrome.enable = true;
  programs.firefox.enable = true;
  programs.librewolf.enable = true;
  programs.qutebrowser.enable = true;
  programs.ssh.enable = true;
  programs.nix-index.enable = false;
  programs.nix-index.enableZshIntegration = config.programs.nix-index.enable;
  # trial
  programs.yazi.enable = true;

  my.shellInitExtra = ''
    function ya() {
      # change the current working directory when yazi exiting
      tmp="$(mktemp -t "yazi-cwd.XXXXX")"
      yazi --cwd-file="$tmp"
      if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';

  services.flameshot.enable = true;
  services.dunst.enable = false;
  services.picom.enable = true;
  services.polybar.enable = true;
  services.polybar.settings = {
    "module/temperature" = {
      # $ for i in /sys/class/thermal/thermal_zone*; do echo "$i: $(<$i/type)"; done
      thermal-zone = 1; # x86_pkg_temp
      # $ for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done
      hwmon-path =
        "/sys/devices/platform/coretemp.0/hwmon/hwmon2/temp1_input"; # Package id 0
      base.temperature = 50;
      warn.temperature = 75;
    };
    "module/gpu" = {
      exec = pkgs.writeShellScript "polybar-nvidia-gpu-util" ''
        printf '%s%%' "$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)"
      '';
    };
  };
  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;

  gtk.enable = true;

  xsession.windowManager.i3.enable = true;
  xsession.windowManager.i3.config.terminal = "kitty";
  #    $ xrandr --query | grep " connected"
  #    DP-0 connected primary 3840x1600+2560+985 (normal left inverted right x axis y axis) 880mm x 367mm
  #
  #    # given, 24.5 mm per inch
  #    $ bc
  #    3880/(880/24.5)
  #    110
  #    1600/(367/24.5)
  #    114
  xresources.properties."Xft.dpi" = "96";

  # Install a JSON formatted list of all Home Manager options. This can be located at <profile directory>/share/doc/
  # home-manager/options.json, and may be used for navigating definitions, auto-completing, and other miscellaneous tasks.
  manual.json.enable = true;

  home.packages = with pkgs; [
    (rust-bin.selectLatestNightlyWith
      (toolchain: toolchain.default.override { }))
    # deadd-notification-center
    btrfs-progs
    dbeaver
    etcd
    google-cloud-sdk
    plantuml
    gradle
  ];
  home.username = "logan";
  home.homeDirectory = "/home/logan";
  home.stateVersion = "22.11";

  nix.enable = true;
  nix.package = pkgs.nixUnstable;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    warn-dirty = false;
    accept-flake-config = true;
    run-diff-hook = true;
    show-trace = true;
  };

  # nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1u" ];
}
