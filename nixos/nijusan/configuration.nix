{
  self,
  inputs',
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    # inputs.agenix.nixosModules.age
    inputs.hermes-agent.nixosModules.default
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
    ./kernel-configuration.nix
  ];

  networking.hostName = "nijusan";

  services.caddy = {
    enable = true;
    email = "contact@llinn.dev";
    openFirewall = true;
    resume = true;
    enableReload = true;
    environmentFile = "/run/secrets/caddy.env";
    globalConfig = ''
      {
        admin :2019 {
          origins http://localhost:2019
          enforce_origin
        }
        grace_period 10s
      }
    '';
    virtualHosts."dashboard.hermes.nijusan.internal" = {
      serverAliases = [
        "dashboard.hermes.nijusan.local"
        "dashboard.hermes.local"
        "dashboard.hermes.internal"
      ];
      extraConfig = ''
        # .internal is not a public TLD, so ACME can't issue a cert.
        # Use Caddy's local CA to serve HTTPS with a self-signed cert.
        tls internal
        handle {
          reverse_proxy 127.0.0.1:9119
        }
      '';
    };
  };

  services.hermes-agent = {
    package = inputs'.hermes-agent.packages.full;
    enable = true;
    configFile = "/home/logan/.hermes/config.yaml";
    addToSystemPackages = true;
    restart = "always";
    restartSec = 5;
  };
  # Hermes dashboard — bound to localhost, exposed via Caddy (HTTPS) above.
  # Runs as the interactive user so it shares the ~/.hermes profile rather
  # than the dedicated `hermes` system user from services.hermes-agent.
  systemd.services.hermes-dashboard = {
    description = "Hermes Agent web dashboard";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "logan";
      Group = "users";
      WorkingDirectory = "/home/logan";
      # --skip-build serves the prebuilt web_dist (no npm/node needed here).
      ExecStart = "/home/logan/.local/bin/hermes dashboard --no-open --skip-build --host 127.0.0.1 --port 9119";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "HOME=/home/logan"
        "PATH=/home/logan/.local/bin:/etc/profiles/per-user/logan/bin:/run/current-system/sw/bin"
      ];
    };
  };
  # services.comfyui.enable = false;
  # services.llama-swap = {
  #   enable = true;
  #   openFirewall = true;
  #   settings = {
  #     logLevel = "info";
  #     models = { };
  #   };
  # };
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  # services.open-webui.enable = false;
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

  users.users.logan.extraGroups = [ "incus-admin" ];

  environment.systemPackages = with pkgs; [
    pciutils
  ];

  system.stateVersion = "25.11";
}
