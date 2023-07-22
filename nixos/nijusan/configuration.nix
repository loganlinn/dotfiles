{ inputs
, config
, pkgs
, lib
, ...
}:

with lib;

{
  # Things to try
  # - https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/undervolt.nix
  # - https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/hardware/fancontrol.nix
  imports = [
    ./hardware-configuration.nix
    ./xserver.nix
  ];

  services.tailscale.enable = true;
  my.tailscale.ssh.enable = true;

  boot.loader = {
    timeout = 3;
    systemd-boot = {
      enable = true;
    };

    grub = {
      enable = false; # TODO
      device = "/dev/disk/by-uuid/C7EA-9458";
    };

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

  };

  boot.plymouth = {
    # enable = false;
    # font = ;
    # logo = ;
    # theme = ;
    # themesPackages = with pkgs; [
    #   catppuccin-plymouth
    #   adi1090x-plymouth-themes
    #   nixos-bgrt-plymouth
    # ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "i915.enable_psr=1"
    "i915.force_probe=a780"
  ];
  boot.kernelModules = [
    "kvm-intel"
  ];
  boot.extraModprobeConfig = lib.mkMerge [
    "options snd_hda_intel power_save=1" # idle audio card after one second
  ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = false; # aggressively autosuspends usb devices. no config available. disable rather than hacking around.
  };

  networking.hostName = "nijusan";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  # services.flatpak.enable = true;

  programs.git.enable = true;

  programs.htop.enable = true;

  programs.dconf.enable = true;

  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "logan" ]; # for polkit agent process (required to use polkit)

  security.polkit.enable = true;

  programs.mosh.enable = true;

  services.davfs2.enable = true;
  services.davfs2.davGroup = "davfs2";

  environment.systemPackages = with pkgs; [
    btrbk
    cachix
    curl
    fd
    killall
    nixos-option
    pciutils
    polkit # used by 1password-gui, etc
    polkit_gnome # polkit agent is required. this seems only option for now
    powertop
    ripgrep
    sysz
    tree
    usbutils
    xdg-utils
    # linuxPackages_latest.perf
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

  my.user = "logan";

  users.users.${config.my.user} = {
    isNormalUser = true;
    home = "/home/logan";
    createHome = true;
    shell = pkgs.zsh;
    packages = with pkgs; [ kubefwd ];
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" "onepassword" "davfs2" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINsEQb9/YUta3lDDKsSsaf515h850CRZEcRg7X0WPGDa"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBwurIVpZjNpRjFva/8loWMCZobZQ3FSATVLC8LX2TDB"
    ];
  };

  security.sudo.enable = true;

  nix = {
    package = pkgs.nixFlakes;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
      trusted-users = [ "logan" ];
    };
    gc.automatic = true; # see also: nix-store --optimise

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "home-manager=${inputs.home-manager}"
    ];
  };

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
