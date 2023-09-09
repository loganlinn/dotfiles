{ flake , config , pkgs , lib , nix-colors, ...  }:

with lib;

let
  inherit (flake.inputs) nixos-hardware;
  inherit (flake.self) nixosModules homeModules;
in
{
  imports = [
    nixos-hardware.outputs.nixosModules.framework-12th-gen-intel
    # nixosModules.bluetooth
    # nixosModules.docker
    nixosModules.networking
    nixosModules.nix-registry
    nixosModules.pipewire
    nixosModules.printing
    nixosModules.security
    # nixosModules.steam
    # nixosModules.tailscale
    # nixosModules.thunar
    # nixosModules.thunderbolt
    ./hardware-configuration.nix
    ./home.nix
  ];

  home-manager.users.${config.my.user.name} = { imports = [./home.nix]; };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.printing.enable = true;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "logan" ]; # for polkit agent process (required to use polkit)
  programs.git.enable = true;
  programs.htop.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.mosh.enable = true;

  security.polkit.enable = true;
  security.sudo.enable = true;

  environment.homeBinInPath = true; # Add ~/bin to PATH
  environment.localBinInPath = true; # Add ~/.local/bin to PATH
  environment.systemPackages = with pkgs; [
    appimage-run
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
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" "onepassword" ];
    openssh.authorizedKeys.keys = config.my.authorizedKeys;
  };

  xdg.portal.enable = true;
  xdg.portal.xdgOpenUsePortal = true;

  documentation.enable = true;
  documentation.dev.enable = true;

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
      allowUnfree = true;
      packageOverrides = pkgs: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
      };
    };

  };

  system.stateVersion = "23.05";
}
