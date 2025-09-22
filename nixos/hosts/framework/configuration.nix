{
  inputs',
  self,
  inputs,
  pkgs,
  hostname,
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
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/cava
    ../../modules/programs/cli/btop
    #../../modules/programs/media/discord
    # ../../modules/programs/media/youtube-music
    # ../../modules/programs/media/obs-studio
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/tlp
    ../../modules/programs/misc/thunar
    # ../../modules/programs/misc/nix-ld
    # ../../modules/programs/misc/virt-manager
    ../../../nix/modules/programs/nixvim
  ];

  networking.hostName = hostname;

  my.hyprland = {
    terminal = "${inputs'.wezterm.packages.default}/bin/wezterm";
  };

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
        slack
        zoom-us
      ];
      programs.emacs.enable = true;
      programs.firefox.enable = true;
      programs.google-chrome.enable = true;
      programs.kitty.enable = true;
      programs.librewolf.enable = true;
      programs.ssh.enable = true;
      programs.wezterm.enable = true;
      programs.nixvim = {
        enable = true;
        defaultEditor = true;
        plugins.lsp.servers.nixd.settings.options = {
          nixos.expr = ''(builtins.getFlake "${self}").nixosConfigurations.${hostname}.options'';
        };
      };
      wayland.windowManager.hyprland =
        let
          primaryMonitors = [
            "Dell Inc. DELL U2723QE 6DS19P3"
          ];
        in
        {
          extraConfig = ''
            # monitor = name, resolution, position, scale
            bindl = , switch:off:[Lid Switch], exec, hyprctl keyword monitor "eDP-1, disable"
            bindl = , switch:on:[Lid Switch], exec, hyprctl keyword monitor "eDP-1, preferred, auto-left, auto"

            # workspace=1,monitor:desc:BNQ BenQ EL2870U PCK00489SL0,default:true
            # workspace=2,monitor:desc:BNQ BenQ EL2870U PCK00489SL0
            # workspace=3,monitor:desc:BNQ BenQ EL2870U PCK00489SL0
            # workspace=4,monitor:desc:BNQ BenQ EL2870U PCK00489SL0

            # workspace=5,monitor:desc:BNQ BenQ EW277HDR 99J01861SL0,default:true
            # workspace=6,monitor:desc:BNQ BenQ EW277HDR 99J01861SL0
            # workspace=7,monitor:desc:BNQ BenQ EW277HDR 99J01861SL0

            # workspace=8,monitor:desc:BNQ BenQ xl2420t 99D06760SL0,default:true
            # workspace=9,monitor:desc:BNQ BenQ xl2420t 99D06760SL0

            # workspace=10,monitor:desc:BNQ BenQ EL2870U PCK00489SL0
          '';
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
    extraGroups = [ "users" ]; # so minidlna can access the files.
  };

  boot.loader = {
    grub.configurationLimit = 10;
    systemd-boot.configurationLimit = 10;
  };
}
