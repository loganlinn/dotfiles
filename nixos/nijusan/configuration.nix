{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.outputs.nixosModules.common-cpu-intel
    inputs.nixos-hardware.outputs.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.outputs.nixosModules.common-pc-ssd
    ./hardware-configuration.nix
    ../modules/tailscale.nix
    ../modules/thunar.nix
    ../modules/titan-security-key.nix
    ../modules/minecraft-server.nix
    ./xserver.nix
  ];

  modules.thunar.enable = true;
  modules.tailscale.enable = true;
  modules.tailscale.ssh.enable = true;
  modules.minecraft-server.enable = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.extraModprobeConfig = lib.mkMerge [
    "options snd_hda_intel power_save=1" # idle audio card after one second
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "i915.enable_psr=1"
    "i915.force_probe=a780"
  ];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # hardware.cpu.intel.updateMicrocode = true;

  hardware.bluetooth.enable = true;

  hardware.pulseaudio = {
    enable = !config.services.pipewire.enable;
    package = pkgs.pulseaudioFull;
    support32Bit = true;
    extraConfig = "
      load-module module-switch-on-connect
    ";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true; # recommended for pipewire

  # environment.variables._JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  # environment.variables.GDK_SCALE = "2";
  # environment.variables.GDK_DPI_SCALE = "0.5";

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
    ];
  };

  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production; # avoid using the bleeding edge here...

  # hardware.logitech.wireless = {
  #   enable = true;
  #   enableGraphical = true;
  # };

  services.hardware.bolt.enable = true;
  services.blueman.enable = true;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.powertop.enable = true;

  # https://wiki.archlinux.org/title/Hardware_video_acceleration#Configuring_VA-API
  environment.variables.LIBVA_DRIVER_NAME = "vdpau";
  environment.variables.VDPAU_DRIVER = "nvidia";
  # The direct backend is currently required on NVIDIA driver series 525 due to a regression
  # (see https://github.com/elFarto/nvidia-vaapi-driver/issues/126)
  environment.variables.NVD_BACKEND = "direct";
  # https://github.com/elFarto/nvidia-vaapi-driver/tree/d628720416812b8db9d62519892b3fdb31076ece
  environment.etc."libva.conf".text = ''
    LIBVA_MESSAGING_LEVEL=1
  '';

  # TODO https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/undervolt.nix
  # TODO https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/fancontrol.nix

  networking.hostName = "nijusan";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.package = pkgs.sudo.override {withInsults = true;}; # do your worst.

  services.printing = {
    enable = true;
    browsing = true;
    drivers = with pkgs; [
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns = true; # resolve .local domains of printers
    openFirewall = true; # for a WiFi printer
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.pcscd.enable = true; # for yubikey smartcard

  # services.yubikey-agent.enable = true;

  # services.flatpak.enable = true;

  programs.git.enable = true;

  programs.htop.enable = true;

  programs.dconf.enable = true;

  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    _1password
    _1password-gui
    alsa-utils # arecord
    btrbk
    bluez
    bluez-alsa
    bluez-tools
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
    xdg-utils
    yubikey-personalization
    libva-utils # vainfo
    # linuxPackages_latest.perf
    ((vim_configurable.override {}).customize {
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
        opt = [];
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
      enableNvidia = (lib.findFirst (x: x == "nvidia") config.services.xserver.videoDrivers) != null;
      autoPrune.enable = true;
      autoPrune.dates = "weekly";
      # rootless.enable = true;
    };
  };

  users.users.logan = {
    isNormalUser = true;
    home = "/home/logan";
    createHome = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel" "networkmanager" "audio" "video" "docker"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsEQb9/YUta3lDDKsSsaf515h850CRZEcRg7X0WPGDa"
    ];
  };

  xdg.portal = {
    enable = true; # needed by pipewire
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.settings.trusted-users = ["logan"];
  nix.gc.automatic = true; # see also: nix-store --optimise

  nixpkgs = {
    config = {
      allowUnfree = true; # NVIDIA drivers, Brother, etc
      allowUnfreePredicate = pkg: true;
      packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
      };
    };
  };

  system.stateVersion = "23.05";
}
