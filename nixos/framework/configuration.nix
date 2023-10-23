{ inputs, self, config , pkgs , lib , nix-colors, ...  }:

with lib;

{
  imports = [
    inputs.nixos-hardware.outputs.nixosModules.framework-12th-gen-intel
    ./hardware-configuration.nix
    self.nixosModules.common
    self.nixosModules._1password
    # self.nixosModules.bluetooth
    # self.nixosModules.docker
    self.nixosModules.networking
    self.nixosModules.nix-registry
    self.nixosModules.pipewire
    self.nixosModules.printing
    self.nixosModules.security
    self.nixosModules.davfs2
    # self.nixosModules.gaming
    self.nixosModules.tailscale
    # self.nixosModules.thunar
    # self.nixosModules.thunderbolt
    self.nixosModules.xserver
    self.nixosModules.wireguard
    self.nixosModules.hyprland
  ];

  my.wireguard.client.enable = true;
  my.wireguard.client.privateKeyFile = "/home/logan/.config/wireguard/firewalla";

  # my.hyprland.enable = false;
  # my.tailscale.ssh.enable = true;
  # my.davfs2.davs."fastmail".url = "https://myfiles.fastmail.com";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "framework";
  networking.networkmanager.enable = true;

  security.polkit.enable = true;

  virtualisation.docker.enable = true;

  services.davfs2.enable = true;
  services.gvfs.enable = true;
  services.printing.cups-pdf.enable = true;
  services.printing.enable = true;
  services.psd.enable = true; # https://wiki.archlinux.org/title/Profile-sync-daemon
  services.tailscale.enable = true;
  services.xserver.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager = {
    lightdm.enable = true;
    lightdm.greeters.slick.enable = true;
    lightdm.greeters.slick.cursorTheme = {
      package = pkgs.numix-cursor-theme;
      name = "Numix-Cursor-Light";
      size = 24;
    };
    defaultSession = "none+xsession";
  };
  services.xserver.windowManager = {
    session = lib.singleton {
      name = "xsession";
      start = ''
        ${pkgs.runtimeShell} "$HOME/.xsession" &
        waitPID=$!
      '';
    };
  };

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs.git.enable = true;
  programs.git.package = pkgs.gitFull;
  programs.htop.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  # programs.dconf.profiles.user.databases = [{
  #   settings."/org/gnome/desktop/input-sources/xkb-options" = ["ctrl:nocaps"];
  # }];

  environment.systemPackages = with pkgs; [
    cachix
    powertop
    pkg-config
    (fenix.complete.withComponents [
      # https://rust-lang.github.io/rustup/concepts/components.html
      "cargo"
      "clippy"
      "rust-docs"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly
    # jetbrains.rust-rover
    restream
  ];

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = optionals config.services.xserver.enable [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  hardware.flipperzero.enable = mkDefault true;
  # hardware.gpgSmartcards.enable = mkDefault true;

  system.stateVersion = "23.05";
}
