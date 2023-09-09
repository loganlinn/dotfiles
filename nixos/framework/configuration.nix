{ flake , config , pkgs , lib , nix-colors, ...  }:

with lib;

let
  inherit (flake.inputs) nixos-hardware;
  inherit (flake.self) nixosModules homeModules;
in
{
  imports = [
    ./hardware-configuration.nix
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
    nixosModules.xserver
  ];

  home-manager.users.${config.my.user.name} = {
    imports = [
      homeModules.common
      nix-colors.homeManagerModule
      # ../../nix/home/awesomewm.nix
      ../../nix/home/dev # TODO module
      ../../nix/home/emacs
      # ../../nix/home/eww
      ../../nix/home/home-manager.nix
      # ../../nix/home/intellij.nix
      # ../../nix/home/kakoune.nix
      ../../nix/home/kitty
      # ../../nix/home/mpd.nix
      # ../../nix/home/mpv.nix
      # ../../nix/home/nnn.nix
      # ../../nix/home/polkit.nix
      ../../nix/home/pretty.nix
      # ../../nix/home/qalculate
      ../../nix/home/ssh.nix
      # ../../nix/home/sync.nix
      # ../../nix/home/urxvt.nix
      # ../../nix/home/vpn.nix
      # ../../nix/home/vscode.nix
      # ../../nix/home/x11.nix
      # ../../nix/home/yt-dlp.nix
      # ../../nix/home/yubikey.nix
      # ../../nix/modules/programs/the-way
      # ../../nix/modules/services
      # ../../nix/modules/spellcheck.nix
      # ../../nix/modules/desktop
      # ../../nix/modules/desktop/browsers
      # ../../nix/modules/desktop/i3
    ];

    colorScheme = nix-colors.colorSchemes.doom-one; # nix-colors

    home.stateVersion = "22.11";
  };

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
