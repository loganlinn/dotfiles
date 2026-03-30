{
  self,
  pkgs,
  ...
}: {
  imports = [
    self.nixosModules._1password
    self.nixosModules.common
    self.nixosModules.docker
    self.nixosModules.networking
    self.nixosModules.nvidia
    self.nixosModules.pipewire
    self.nixosModules.tailscale
    self.nixosModules.xserver
    ./cachix.nix
    ./hardware-configuration.nix
    ./kernel-configuration.nix
  ];

  networking.hostName = "nijusan";

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # desktop — disable GNOME auto-suspend (not a laptop)
  services.power-profiles-daemon.enable = true;

  services.printing.enable = true;
  services.tailscale.enable = true;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs.firefox.enable = true;
  programs.htop.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;

  security.polkit.enable = true;

  virtualisation.docker.enable = true;

  nix.settings.trusted-users = ["root"];

  environment.systemPackages = with pkgs; [
    pciutils
  ];

  system.stateVersion = "25.11";
}
