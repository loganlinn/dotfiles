{ flake, config, pkgs, lib, ... }:

with lib;

let inherit (flake) self;
in {
  imports = [
    self.nixosModules.secrets
    self.nixosModules.common
    self.nixosModules.bluetooth
    self.nixosModules.davfs2
    self.nixosModules.docker
    self.nixosModules.networking
    self.nixosModules.nix-registry
    self.nixosModules.nvidia
    self.nixosModules.pipewire
    self.nixosModules.printing
    self.nixosModules.security
    self.nixosModules.steam
    self.nixosModules.tailscale
    self.nixosModules.thunar
    self.nixosModules.thunderbolt
    self.nixosModules.xserver
    ./hardware-configuration.nix
    ./kernel-configuration.nix
  ];

  my.user.name = "logan";
  my.tailscale.ssh.enable = true;

  networking.hostName = "nijusan";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners =
    [ "logan" ]; # for polkit agent process (required to use polkit)
  programs.git.enable = true;
  programs.htop.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.mosh.enable = true;
  # programs.hyprland.enable = true;
  # programs.hyprland.enableNvidiaPatches = true;

  security.polkit.enable = true;

  services.tailscale.enable = true;
  services.davfs2.enable = true;
  # services.tumbler.enable = mkDefault true; # thunar thumbnail support for images
  services.gvfs.enable =
    lib.mkDefault true; # thunar mount, trash, and other functionalities
  # services.flatpak.enable = true;
  services.xserver.enable = true;

  environment.homeBinInPath = true; # Add ~/bin to PATH
  environment.localBinInPath = true; # Add ~/.local/bin to PATH
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

  users.users.${config.my.user.name} = {
    shell = config.my.shell;
    isNormalUser = true;
    home = "/home/${config.my.user.name}";
    createHome = true;
    packages = with pkgs; [ kubefwd ];
    extraGroups =
      [ "wheel" "networkmanager" "audio" "video" "docker" "onepassword" "${config.services.davfs2.davGroup}"];
    openssh.authorizedKeys.keys = config.my.authorizedKeys;
  };

  security.sudo.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  documentation.enable = true;
  documentation.dev.enable = true;
  # documentation.man-db.enable = true;
  documentation.nixos.extraModules = [

  ];

  nix = {
    package = pkgs.nixFlakes;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
      trusted-users = [ "logan" ];
    };
    gc.automatic = true; # see also: nix-store --optimise

    nixPath = [
      "nixpkgs=${flake.inputs.nixpkgs}"
      "home-manager=${flake.inputs.home-manager}"
    ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true; # NVIDIA drivers, Brother, etc
      allowUnfreePredicate = pkg: true;
      packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball
          "https://github.com/nix-community/NUR/archive/master.tar.gz") {
            inherit pkgs;
          };
      };
    };

  };

  system.stateVersion = "23.05";
}
