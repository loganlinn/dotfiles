{
  self,
  pkgs,
  ...
}:
{
  imports = [
    self.nixosModules._1password
    self.nixosModules.comfyui
    self.nixosModules.common
    self.nixosModules.docker
    # self.nixosModules.hyprland
    self.nixosModules.networking
    self.nixosModules.nvidia
    self.nixosModules.ollama
    self.nixosModules.open-webui
    self.nixosModules.pipewire
    self.nixosModules.printing
    self.nixosModules.tailscale
    self.nixosModules.xserver
    ./cachix.nix
    ./hardware-configuration.nix
    ./kernel-configuration.nix
  ];

  networking.hostName = "nijusan";

  services.atuin.enable = true;
  services.atuin.host = "127.0.0.1";
  services.atuin.openFirewall = false;
  services.atuin.maxHistoryLength = 8192 * 4;

  services.caddy.enable = true;
  services.caddy.virtualHosts."nijusan.royal-bee.ts.net" = {
    extraConfig = ''
      handle_path /atuin/* {
        reverse_proxy localhost:8888
      }
      tls {
        get_certificate tailscale
      }
    '';
  };
  services.comfyui.enable = false;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.open-webui.enable = false;
  services.power-profiles-daemon.enable = true;
  services.printing.enable = true;
  services.tailscale.enable = true;
  services.xserver.enable = true;

  programs._1password-gui.enable = true;
  programs._1password.enable = true;
  programs.dconf.enable = true;
  programs.firefox.enable = true;
  programs.htop.enable = true;
  programs.nix-ld.enable = true;
  programs.zsh.enable = true;

  security.polkit.enable = true;

  # desktop - disable auto-suspend entirely (was causing periodic network drops)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # virtualisation.docker.enable = true;
  virtualisation.incus.enable = true;
  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [ "incusbr0" ];

  nix.settings.trusted-users = [ "root" ]; # this is in addition to my.user.name (needed?)

  users.users.logan.extraGroups = [ "incus-admin" ];

  environment.systemPackages = with pkgs; [
    pciutils
  ];

  system.stateVersion = "25.11";
}
