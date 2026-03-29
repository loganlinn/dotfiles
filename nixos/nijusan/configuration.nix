{
  self,
  pkgs,
  ...
}: {
  imports = [
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

  services.printing.enable = true;
  services.tailscale.enable = true;

  programs.firefox.enable = true;
  programs.htop.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;

  security.polkit.enable = true;

  virtualisation.docker.enable = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dde0946WDTTkh8+bZQITgBR7ZMEH2eyJw="
    ];
    trusted-users = ["root" "logan"];
  };

  environment.systemPackages = with pkgs; [
    pciutils
  ];

  system.stateVersion = "25.11";
}
