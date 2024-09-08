{
  self,
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

with lib;

{
  imports = [
    ./hardware-configuration.nix
    ../../nix/modules/programs/nixvim
    inputs.nixvim.nixosModules.nixvim
    inputs.agenix.nixosModules.age
    self.nixosModules.home-manager
    self.nixosModules._1password
    self.nixosModules.common
    self.nixosModules.pipewire
  ];

  boot.kernelParams = [ ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.systemd-boot.netbootxyz.enable = false; # TODO try it!
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;

  networking.hostName = "juuni";
  networking.networkmanager.enable = true;
  networking.interfaces.enp3s0.wakeOnLan.enable = true;
  networking.interfaces.enp3s0.wakeOnLan.policy = [ "magic" ];

  time.timeZone = "America/Los_Angeles";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  services.xserver.desktopManager.gnome.enable = true;

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # services.displayManager.autoLogin.enable = true;

  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  home-manager.users.${config.my.user.name} =
    {
      self,
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        self.homeModules.common
        self.homeModules.secrets
        ../../nix/home/dev # TODO module
        ../../nix/home/pretty.nix
        ../../nix/home/ssh.nix
      ];

      home.stateVersion = "24.05";
    };

  environment.systemPackages = with pkgs; [
    vim
    arion
    docker-client # used by podman
  ];

  virtualisation.docker.enable = false;
  virtualisation.podman.dockerCompat = mkDefault true;
  virtualisation.podman.dockerSocket.enable = mkDefault true;
  virtualisation.podman.defaultNetwork.settings.dns_enabled = mkDefault true;

  services.openssh.enable = true;

  virtualisation.podman.enable = true;

  nix.sshServe.enable = true;
  nix.sshServe.write = true;
  nix.sshServe.keys = config.my.authorizedKeys;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}