{
  self,
  inputs,
  pkgs,
  hostname,
  editor,
  ...
}:
{
  imports = [
    self.nixosModules.home-manager
    ./hardware-configuration.nix
    inputs.nixvim.nixosModules.nixvim
    ../common.nix
    ../../modules/1password.nix
    ../../modules/common.nix
    ../../modules/thunderbolt.nix
    ../../modules/hardware/video/intel.nix
    ../../modules/hardware/drives
    ../../modules/desktop/hyprland
    #../../modules/programs/games
    ../../modules/programs/browser/floorp
    ../../modules/programs/cli/tmux
    # ../../modules/programs/cli/direnv
    # ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/cava
    ../../modules/programs/cli/btop
    #../../modules/programs/media/discord
    # ../../modules/programs/media/spicetify
    # ../../modules/programs/media/youtube-music
    # ../../modules/programs/media/thunderbird
    # ../../modules/programs/media/obs-studio
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/tlp
    ../../modules/programs/misc/thunar
    # ../../modules/programs/misc/nix-ld
    # ../../modules/programs/misc/virt-manager
    ../../../nix/modules/programs/nixvim
  ];

  networking.hostName = hostname;
  
  # home-manager.users.logan = import ./home.nix; # TODO unify with nijusan
  home-manager.sharedModules = [
    (_: {
      imports = [
        # ../../../nix/home/aider.nix
        # ../../../nix/home/secrets.nix
        # ../../../nix/home/sync.nix
        # ../../../nix/home/urxvt.nix
        # ../../../nix/home/vpn.nix
        # ../../../nix/home/vscode.nix
        # ../../../nix/modules/services
        # ../../../nix/modules/spellcheck.nix
        # self.homeModules.common
        # self.homeModules.nix-colors
        ../../../nix/home/common
        ../../../nix/home/dev
        ../../../nix/home/dev/lua.nix
        ../../../nix/home/dev/nodejs.nix
        ../../../nix/home/doom
        ../../../nix/home/emacs
        ../../../nix/home/home-manager.nix
        ../../../nix/home/just
        ../../../nix/home/kitty
        ../../../nix/home/neovide.nix
        ../../../nix/home/nixvim
        ../../../nix/home/pretty.nix
        ../../../nix/home/ssh.nix
        ../../../nix/home/tmux.nix
        ../../../nix/home/wezterm
        ../../../nix/home/yazi
        ../../../nix/home/yt-dlp.nix
      ];
      home.packages = with pkgs; [
        uv
      ];
      programs.emacs.enable = true;
      programs.google-chrome.enable = true;
      programs.firefox.enable = true;
      programs.librewolf.enable = true;
      programs.ssh.enable = true;
      programs.wezterm.enable = true;
      programs.nixvim = {
        enable = true;
        defaultEditor = true;
        plugins.lsp.servers.nixd.settings.options = {
          nixos.expr = ''(builtins.getFlake "${self}").nixosConfigurations.framework.options'';
        };
      };
    })
  ];

  environment.systemPackages = with pkgs; [
     pciutils
     usbutils
     usbrip
     usbtop
     powertop
  ];
  
  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  services.minidlna = {
    enable = true;
    openFirewall = true;
    settings = {
      friendly_name = "NixOS-DLNA";
      media_dir = [
        # A = Audio, P = Pictures, V, = Videos, PV = Pictures and Videos.
        # "A,/mnt/work/Pimsleur/Russian"
        "/mnt/work/Pimsleur"
        "/mnt/work/Media/Films"
        "/mnt/work/Media/Series"
        "/mnt/work/Media/Videos"
        "/mnt/work/Media/Music"
      ];
      inotify = "yes";
      log_level = "error";
    };
  };
  users.users.minidlna = {
    extraGroups = ["users"]; # so minidlna can access the files.
  };

  boot.loader = {
    grub.configurationLimit = 10;
    systemd-boot.configurationLimit = 10;
  };
}
