{
  self,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    self.nixosModules._1password
    # self.nixosModules.comfyui
    self.nixosModules.common
    self.nixosModules.docker
    # self.nixosModules.llama-swap
    # self.nixosModules.hyprland
    self.nixosModules.networking
    self.nixosModules.nvidia
    # self.nixosModules.ollama
    # self.nixosModules.open-webui
    self.nixosModules.pipewire
    self.nixosModules.printing
    self.nixosModules.tailscale
    self.nixosModules.xserver
    ./cachix.nix
    ./hardware-configuration.nix
    ./hermes-agent.nix
    ./kernel-configuration.nix
  ];

  networking.hostName = "nijusan";

  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsKey = "";
    age.keyFile = "/home/logan/.config/sops/age/keys.txt";
  };

  services.caddy = {
    enable = true;
    email = "contact@llinn.dev";
    openFirewall = true;
    resume = true;
    enableReload = true;
    globalConfig = ''
      admin {
        origins http://localhost:2019
        enforce_origin
      }
      grace_period 10s
    '';
  };

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
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
  # virtualisation.incus.preseed = {
  #   networks = [
  #     {
  #       name = "incusbr0";
  #       type = "bridge";
  #       config = {
  #         "ipv4.address" = "10.235.175.1/24";
  #         "ipv4.nat" = "true";
  #         "ipv6.address" = "fd42:bd4:e2f:2828::1/64";
  #         "ipv6.nat" = "true";
  #       };
  #     }
  #   ];
  #   storage_pools = [
  #     {
  #       name = "default";
  #       driver = "btrfs";
  #       config = {
  #         size = "19GiB";
  #         source = "/var/lib/incus/disks/default.img";
  #       };
  #     }
  #   ];
  #   profiles = [
  #     {
  #       name = "default";
  #       devices = {
  #         eth0 = {
  #           name = "eth0";
  #           network = "incusbr0";
  #           type = "nic";
  #         };
  #         root = {
  #           path = "/";
  #           pool = "default";
  #           type = "disk";
  #         };
  #       };
  #     }
  #   ];
  # };
  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [ "incusbr0" ];
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
    8443
  ];

  nix.settings.trusted-users = [ "root" ]; # this is in addition to my.user.name (needed?)

  users.users.logan.extraGroups = [
    "incus-admin"
  ];

  environment.systemPackages = with pkgs; [
    bubblewrap # codex standalone install
    pciutils
  ];

  system.stateVersion = "25.11";
}
