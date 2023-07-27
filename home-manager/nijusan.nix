{ self'
, config
, pkgs
, lib
, nix-colors
, ...
}:
let
  inherit (nix-colors.lib.contrib { inherit pkgs; }) nixWallpaperFromScheme;
in
{
  imports = [
    nix-colors.homeManagerModule
    ../nix/home/common.nix
    ../nix/home/dev # TODO module
    #../nix/home/dev/vala.nix
    ../nix/home/dunst
    ../nix/home/emacs.nix
    ../nix/home/eww
    ../nix/home/home-manager.nix
    ../nix/home/intellij.nix
    ../nix/home/kitty
    ../nix/home/mpd.nix
    ../nix/home/mpv.nix
    ../nix/home/nnn.nix
    ../nix/home/polkit.nix
    ../nix/home/pretty.nix
    ../nix/home/qalculate
    ../nix/home/sync.nix
    ../nix/home/urxvt.nix
    ../nix/home/vpn.nix
    ../nix/home/vscode.nix
    ../nix/home/x11.nix
    ../nix/home/yt-dlp.nix
    ../nix/home/yubikey.nix
    ../nix/modules/programs/the-way
    ../nix/modules/services
    ../nix/modules/spellcheck.nix
    ../nix/modules/fonts.nix
    ../nix/modules/desktop
    ../nix/modules/desktop/browsers
    ../nix/modules/desktop/browsers/firefox.nix
    ../nix/modules/desktop/i3
  ];

  programs.vscode.enable = false;

  programs.kakoune = {
    enable = true;
    config.numberLines.relative = true;
    plugins = with pkgs.kakounePlugins; [
      auto-pairs-kak
      connect-kak
      fzf-kak
      kak-lsp
      kak-ansi
      kakoune-rainbow
      # parinfer-rust
      powerline-kak
      prelude-kak
      rep
    ];
  };

  sops.defaultSopsFile = ../secrets/default.yaml;
  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  sops.secrets.github_token.sopsFile = ../secrets/default.yaml;

  modules.fonts.enable = true;
  modules.spellcheck.enable = true;
  modules.theme = {
    active = "arc";
    # wallpaper = ../wallpaper/wallhaven-weq8y7.png;
    wallpaper = nixWallpaperFromScheme {
      scheme = config.colorscheme;
      width = 3840;
      height = 1600;
      logoScale = 4.0;
    };
  };
  modules.desktop.browsers = {
    default = "${lib.getExe config.programs.google-chrome.package} '--profile-directory=Profile 1'"; # work
    alternate = "${lib.getExe config.programs.google-chrome.package} '--profile-directory=Default'"; # personal
  };

  xsession.windowManager.i3.enable = true;
  xsession.windowManager.i3.config.terminal = "kitty";

  gtk.enable = true;
  colorScheme = nix-colors.colorSchemes.doom-one; # nix-colors

  programs.google-chrome.enable = true;
  programs.firefox.enable = true;
  programs.librewolf.enable = true;
  programs.qutebrowser.enable = true;

  programs.rofi.enable = true;

  programs.the-way = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.obs-studio = {
    enable = true;
    plugins = [
    ];
  };

  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    forwardAgent = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/%C";
    controlPersist = "60m";
    serverAliveInterval = 120;
    includes = ["${config.home.homeDirectory}/.ssh/config.local"];
    matchBlocks = {
      "fire.walla" = {
        user = "pi";
      };
    };
    extraConfig = ''
      TCPKeepAlive yes

      Host *
        IdentityAgent ~/.1password/agent.sock
    '';
  };

  services.dunst.enable = true;

  services.flameshot.enable = true;

  services.polybar = {
    enable = true;
    settings = {
      "module/temperature" = {
        # $ for i in /sys/class/thermal/thermal_zone*; do echo "$i: $(<$i/type)"; done
        thermal-zone = 1; # x86_pkg_temp
        # $ for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done
        hwmon-path = "/sys/devices/platform/coretemp.0/hwmon/hwmon2/temp1_input"; # Package id 0
        base.temperature = 50;
        warn.temperature = 75;
      };
      "module/gpu" = {
        exec = pkgs.writeShellScript "polybar-nvidia-gpu-util" ''
          printf '%s%%' "$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)"
        '';
      };
    };
  };

  modules.polybar = {
    networks = [
      {
        interface = "eno3";
        interface-type = "wired";
      }
      {
        interface = "wlo1";
        interface-type = "wireless";
      }
    ];
  };

  services.picom.enable = true;

  services.betterlockscreen = {
    enable = true;
    arguments = [ "-w" "dim" ];
    inactiveInterval = 15; # minutes
  };

  xdg.configFile."betterlockscreen/betterlockscreenrc".source = ../config/betterlockscreen/betterlockscreenrc;

  services.easyeffects.enable = false; # causing glitching on twitch streams

  #
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

  # services.emanote = {
  #   enable = true;
  #   notes = [
  #     "${config.home.homeDirectory}/Sync/Notes"
  #   ];
  #   package = flake.inputs.emanote.packages.${system}.default;
  # };

  # pkgs.fetchFromGitHub {
  #   owner = "kdave";
  #   repo = "btrfsmaintenance";
  #   rev = "be42cb6267055d125994abd6927cf3a26deab74c";
  #   hash = "sha256-wD9AWOaYtCZqU2YIxO6vEDIHCNQBygvFzRHW3LOQRqk=";
  # };

  # Install a JSON formatted list of all Home Manager options. This can be located at <profile directory>/share/doc/
  # home-manager/options.json, and may be used for navigating definitions, auto-completing, and other miscellaneous tasks.
  manual.json.enable = true;

  home.packages = with pkgs; [
    self'.packages.graphite-cli
    # audacity
    # btrfs-snap # https://github.com/jf647/btrfs-snap
    # nemo
    (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override { }))
    btrfs-progs
    dbeaver
    google-cloud-sdk
    plantuml
    # github-desktop # requires gnome-keyring...
    etcd
  ];

  home.username = "logan";

  home.homeDirectory = "/home/logan";

  home.stateVersion = "22.11";

  nix = {
    enable = true;
    package = pkgs.nixUnstable;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
      accept-flake-config = true;
      # bash-prompt = ;
      # bash-prompt-prefix = ;
      # bash-prompt-suffix = ;
      # plugin-files = [];
      run-diff-hook = true;
      show-trace = true;
      # use-xdg-base-directories = true; # Warning: This changes the location of some well-known symlinks that Nix creates, which might break tools that rely on the old, non-XDG-conformant locations.
      # In particular, the following locations change:
      # ~/.nix-profile  => $XDG_STATE_HOME/nix/profile
      # ~/.nix-defexpr  => $XDG_STATE_HOME/nix/defexpr
      # ~/.nix-channels => $XDG_STATE_HOME/nix/channels
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      # https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _pkg: true;
      permittedInsecurePackages = [
        "openssl-1.1.1u"
      ];
    };
  };
}
