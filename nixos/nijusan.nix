{ config
, lib
, pkgs
, ...
}:
let
  enableKDE = false;
in
{
  imports = [
    ./hardware-configuration.nix
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/gpu/nvidia>
    <nixos-hardware/common/pc/ssd>
    ./tailscale.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = lib.mkMerge [
    # idle audio card after one second
    "options snd_hda_intel power_save=1"
    # enable wifi power saving (keep uapsd off to maintain low latencies)
    # "options iwlwifi power_save=1 uapsd_disable=1"
  ];

  hardware.bluetooth.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    support32Bit = true;
  };
  hardware.video.hidpi.enable = lib.mkDefault true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [ vaapiVdpau ];
  hardware.nvidia.powerManagement.enable = true;
  # https://wiki.archlinux.org/title/Hardware_video_acceleration#Configuring_VA-API
  environment.variables.LIBVA_DRIVER_NAME = "vdpau";
  environment.variables.VDPAU_DRIVER = "nvidia";
  # https://github.com/elFarto/nvidia-vaapi-driver/tree/d628720416812b8db9d62519892b3fdb31076ece
  environment.etc."libva.conf".text = ''
    LIBVA_MESSAGING_LEVEL=1
  '';

  powerManagement.enable = true;

  # TODO https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/undervolt.nix
  # TODO https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/fancontrol.nix

  networking.hostName = "nijusan";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  sound.enable = true;

  services.hardware.bolt.enable = true;

  services.xserver =
    {
      enable = true;
      layout = "us";
      xkbOptions = "ctrl:nocaps"; # Make Caps Lock a Control key
      autorun = true;
    }
    // (
      if enableKDE
      then {
        displayManager = {
          sddm.enable = true;
          plasma5.enable = true;
        };
      }
      else {
        displayManager = {
          lightdm.enable = true;
          lightdm.greeters.mini = {
            enable = true;
            user = "logan";
            #             extraConfig = ''
            #               [greeter]
            #               show-password-label = false
            #               [greeter-theme]
            #               background-image = ""
            #             '';
          };
          defaultSession = "none+xsession";
          # autoLogin.enable = true;
          # autoLogin.user = "logan";
        };

        windowManager = {
          session = lib.singleton {
            name = "xsession";
            start = ''
              ${pkgs.runtimeShell} "$HOME/.xsession" &
              waitPID=$!
            '';
          };
        };
      }
    );

  services.printing = {
    enable = true;
    browsing = true;
    drivers = with pkgs; [
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
    ];
  };

  # service discovery
  services.avahi = {
    enable = true;
    nssmdns = true; # resolve .local domains of printers
    openFirewall = true; # for a WiFi printer
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
  };

  services.pcscd.enable = true; # for yubikey smartcard

  # services.yubikey-agent.enable = true;

  # services.flatpak.enable = true;

  services.tumbler.enable = !enableKDE; # thunar thumbnail support for images

  services.gvfs.enable = !enableKDE; # thunar mount, trash, and other functionalities

  programs.git.enable = true;

  programs.htop.enable = true;

  programs.dconf.enable = true;

  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.mosh.enable = true;

  programs.kdeconnect.enable = enableKDE;

  programs.thunar = lib.mkIf (!enableKDE) {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  environment.systemPackages = with pkgs;
    [
      _1password
      _1password-gui
      btrbk
      cachix
      curl
      exa
      fd
      killall
      nixos-option
      pciutils
      powertop
      ripgrep
      sysz
      tmux
      tree
      steam
      usbutils
      wget
      xclip
      yubikey-personalization
    ]
    ++ lib.optionals enableKDE [
      plasma5Packages.plasma-thunderbolt
      libsForQt5.bismuth
    ]
    ++ lib.optionals (!enableKDE) [
      xfce.thunar
    ]
    ++ [
      ((vim_configurable.override { }).customize {
        name = "vim";
        vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
          start = [
            vim-commentary
            vim-eunuch
            vim-lastplace
            vim-nix
            vim-repeat
            vim-sensible
            vim-sleuth
            vim-surround
            vim-unimpaired
          ];
          opt = [ ];
        };
        vimrcConfig.customRC = ''
          let mapleader = "\<Space>"
          " system clip
          set clipboard=unnamed
          " yank to system clipboard without motion
          nnoremap <Leader>y "+y
          " yank line to system clipboard
          nnoremap <Leader>yl "+yy
          " yank file to system clipboard
          nnoremap <Leader>yf gg"+yG
          " paste from system clipboard
          nnoremap <Leader>p "+p
        '';
      })
    ];

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      autoPrune.dates = "weekly";
    };
  };

  users.users = {
    logan = {
      isNormalUser = true;
      home = "/home/logan";
      createHome = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "networkmanager" "video" "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsEQb9/YUta3lDDKsSsaf515h850CRZEcRg7X0WPGDa"
      ];
    };
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.trusted-users = [ "logan" ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true; # NVIDIA drivers, etc
      packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
      };
    };
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "23.05";
}
