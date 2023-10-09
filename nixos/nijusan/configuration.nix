{ self, config, pkgs, lib, ... }:

with lib;

{
  imports = [
    self.nixosModules.common
    self.nixosModules._1password
    self.nixosModules.bluetooth
    self.nixosModules.davfs2
    self.nixosModules.docker
    self.nixosModules.gaming
    self.nixosModules.networking
    self.nixosModules.nix-registry
    self.nixosModules.nvidia
    self.nixosModules.pipewire
    self.nixosModules.printing
    self.nixosModules.security
    self.nixosModules.tailscale
    self.nixosModules.thunar
    self.nixosModules.thunderbolt
    self.nixosModules.vivaldi
    self.nixosModules.xserver
    self.nixosModules.hyprland
    ./hardware-configuration.nix
    ./kernel-configuration.nix
  ];

  my.davfs2.davs."fastmail".url = "https://myfiles.fastmail.com";
  my.hyprland.enable = false;
  my.tailscale.ssh.enable = true;
  my.vivaldi.enable = true;

  networking.hostName = "nijusan";
  networking.networkmanager.enable = true;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs.git.enable = true;
  programs.git.package = pkgs.gitFull;
  programs.htop.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.mosh.enable = true;

  security.polkit.enable = true;

  services.printing.enable = true;
  services.printing.browsing = true; # advertise shared printers
  services.printing.cups-pdf.enable = true;
  services.psd.enable = true; # https://wiki.archlinux.org/title/Profile-sync-daemon
  services.tailscale.enable = true;
  services.davfs2.enable = true;
  services.gvfs.enable = true; # thunar mount, trash, and other functionalities
  # services.flatpak.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
  '';

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    btrbk
    cachix
    pciutils
    powertop
  ];

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = optionals config.services.xserver.enable [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  services.xserver.enable = true;
  services.xserver.displayManager = mkIf config.services.xserver.enable {
    lightdm.enable = config.services.xserver.enable;
    lightdm.greeters.slick.enable = config.services.xserver.enable;
    lightdm.greeters.slick.cursorTheme = {
      package = pkgs.numix-cursor-theme;
      name = "Numix-Cursor-Light";
      size = 24;
    };
    defaultSession = "none+xsession";
  };
  services.xserver.windowManager = mkIf config.services.xserver.enable {
    session = lib.singleton {
      name = "xsession";
      start = ''
        ${pkgs.runtimeShell} "$HOME/.xsession" &
        waitPID=$!
      '';
    };
  };
  # | Display Mode | Freq (Hz)    | PxClk (MHz) | Sync Polarity |
  # |--------------|--------------|-------------|---------------|
  # |  640 x 400   | 31.5 / 70.1  | 25.2        | -/+           |
  # |  640 x 480   | 31.5 / 59.9  | 25.2        | -/-           |
  # |  640 x 480   | 37.5 / 75.0  | 31.5        | -/-           |
  # |  720 x 400   | 31.5 / 70.1  | 28.3        | -/+           |
  # |  800 x 600   | 37.9 / 60.3  | 40.0        | +/+           |
  # |  800 x 600   | 46.9 / 75.0  | 49.5        | +/+           |
  # | 1024 x 768   | 48.4 / 60.0  | 65          | -/-           |
  # | 1024 x 768   | 60.0 / 75.0  | 78.8        | +/+           |
  # | 1152 x 864   | 67.5 / 75.0  | 108         | +/+           |
  # | 1280 x 800   | 49.3 / 59.9  | 71          | +/-           |
  # | 1280 x 1024  | 64.0 / 60.0  | 108         | +/+           |
  # | 1280 x 1024  | 80.0 / 75.0  | 135         | +/+           |
  # | 1600 x 1200  | 75.0 / 60.0  | 162         | +/+           |
  # | 1920 x 1080  | 67.5 / 60.0  | 148.5       | +/+           |
  # | 2560 x 1440  | 88.8 / 60.0  | 241.5       | +/-           |
  # | 3840 x 1600  | 98.8 / 60.0  | 395         | +/-           |
  services.xserver.monitorSection = ''
    VendorName  "Unknown"
    ModelName   "DELL U3818DW"
    HorizSync    25.0 - 115.0
    VertRefresh  24.0 - 85.0
    Option      "DPMS"
  '';
  services.xserver.deviceSection = ''
    BoardName   "NVIDIA RTX A4000"
  '';
  services.xserver.screenSection = ''
    DefaultDepth    24
    Option         "Stereo" "0"
    Option         "nvidiaXineramaInfoOrder" "DFP-0"
    Option         "metamodes" "DP-0: nvidia-auto-select +2560+1135, DP-2: nvidia-auto-select +0+0"
    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
    SubSection     "Display"
        Depth       24
    EndSubSection
  '';

  hardware.flipperzero.enable = true;

  system.stateVersion = "23.05";
}
