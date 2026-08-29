{
  self,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    inputs.microvm.nixosModules.microvm
    inputs.sops-nix.nixosModules.sops
    inputs.nixvim.nixosModules.nixvim
    ../../nix/modules/programs/nixvim
    self.nixosModules.common
    self.nixosModules.docker
    self.nixosModules.home-manager
    self.nixosModules.networking
    self.nixosModules.syncthing
    self.nixosModules.tailscale
    ./hermes-agent.nix
  ];

  home-manager.users.logan = import ../../home-manager/microvm.nix;

  networking.hostName = "microvm";

  # Headless VM: drive the network with systemd-networkd instead of
  # NetworkManager (which expects a desktop/interactive host).
  networking.networkmanager.enable = mkForce false;
  networking.useNetworkd = true;
  networking.useDHCP = false;
  systemd.network.enable = true;
  systemd.network.networks."20-lan" = {
    matchConfig.Type = "ether";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
    };
  };

  # sops-nix decrypts at activation using this host's SSH key. The host's age
  # key (derive with `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`) must be
  # added to .sops.yaml and the secrets re-encrypted before hermes can start.
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  services.openssh.enable = true;
  services.syncthing.enable = true;
  services.tailscale.enable = true;

  virtualisation.docker.enable = true;

  security.polkit.enable = true;

  programs.git.enable = true;
  programs.git.package = pkgs.gitFull;
  programs.htop.enable = true;
  programs.zsh.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.nixvim.enable = true;
  programs.nixvim.defaultEditor = true;

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
  ];

  # ---- microvm.nix guest definition -------------------------------------
  # Build with: nix build .#nixosConfigurations.microvm.config.microvm.declaredRunner
  # or run directly: nix run .#nixosConfigurations.microvm.config.microvm.declaredRunner
  microvm = {
    hypervisor = "qemu";
    vcpu = 4;
    mem = 4096;

    interfaces = [
      {
        type = "tap";
        id = "vm-microvm";
        mac = "02:00:00:00:00:01";
      }
    ];

    # Share the host's read-only Nix store over virtiofs and keep guest store
    # writes on a persistent overlay volume, rather than baking a full store
    # image into the VM.
    shares = [
      {
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        proto = "virtiofs";
      }
    ];
    writableStoreOverlay = "/nix/.rw-store";

    volumes = [
      {
        image = "microvm-nix-overlay.img";
        mountPoint = "/nix/.rw-store";
        size = 8192; # 8 GiB
      }
      {
        image = "microvm-var.img";
        mountPoint = "/var";
        size = 16384; # 16 GiB — hermes + syncthing + docker state
      }
    ];
  };

  system.stateVersion = "23.05";
}
