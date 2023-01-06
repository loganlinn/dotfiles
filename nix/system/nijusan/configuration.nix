{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./tailscale.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nijusan";
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
  '';

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  # KDE Plasma
  # https://nixos.wiki/wiki/KDE
  # https://github.com/NixOS/nixpkgs/tree/master/pkgs/desktops/plasma-5
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:nocaps"; # Make Caps Lock a Control key

  sound.enable = true;

  services.printing.enable = true;
  services.printing.browsing = true;

  services.printing.drivers = with pkgs; [
    brlaser
    brgenml1lpr
    brgenml1cupswrapper
  ];

  services.avahi.enable = true;
  services.avahi.nssmdns = true;       # resolve .local domains of printers 
  services.avahi.openFirewall = true;  # for a WiFi printer
  # services.ipp-usb.enable = true;    # for a USB printer

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

  environment.systemPackages = with pkgs; [
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
    plasma5Packages.plasma-thunderbolt
    powertop
    ripgrep
    sysz
    tmux
    tree
    steam
    usbutils
    vim_configurable # has basic nix syntax
    wget
    xclip
    yubikey-personalization
  ];

  programs.git.enable = true;

  programs.htop.enable = true;

  programs.dconf.enable = true;

  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.mosh.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.autoPrune.dates = "weekly";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
  };

  services.pcscd.enable = true;
  # services.yubikey-agent.enable = true;

  services.flatpak.enable = true;

  programs.kdeconnect.enable = true;
  # system.copySystemConfiguration = true;

  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  powerManagement = {
    enable = true;
    # powertop.enable = true;
    # cpuFreqGovernor = "powersave";
    # cpuFreqGovernor = "performance";
    # cpuFreqGovernor = "ondemand";
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.trusted-users = [ "logan" ];
  };

  system.stateVersion = "23.05";
}
