{ self, config , pkgs , lib , nix-colors, ...  }:

with lib;

{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.outputs.nixosModules.framework-12th-gen-intel
    self.nixosModules._1password
    # self.nixosModules.bluetooth
    # self.nixosModules.docker
    self.nixosModules.networking
    self.nixosModules.nix-registry
    self.nixosModules.pipewire
    self.nixosModules.printing
    self.nixosModules.security
    # self.nixosModules.gaming
    # self.nixosModules.tailscale
    # self.nixosModules.thunar
    # self.nixosModules.thunderbolt
    self.nixosModules.xserver
  ];

  home-manager.users.${config.my.user.name} = {
    imports = [
      self.homeModules.common
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
    gtk.enable = true;

    programs.kitty.enable = true;
    programs.emacs.enable = true;
    programs.rofi.enable = true;
    programs.google-chrome.enable = true;
    programs.firefox.enable = true;
    programs.librewolf.enable = true;
    programs.qutebrowser.enable = true;
    programs.ssh.enable = true;
    programs.nix-index.enable = false;
    programs.nix-index.enableZshIntegration = config.programs.nix-index.enable;

    home.stateVersion = "22.11";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework";
  networking.networkmanager.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.printing.enable = true;
  services.printing.cups-pdf.enable = true;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs.htop.enable = true;
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    appimage-run
    cachix
    curl
    fd
    killall
    nixos-option
    pciutils
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

  users.users.${config.my.user.name}.extraGroups = [

  ]
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "docker" "onepassword" ];
    openssh.authorizedKeys.keys = config.my.authorizedKeys;
  };

  xdg.portal.enable = true;
  xdg.portal.xdgOpenUsePortal = true;

  system.stateVersion = "23.05";
}
