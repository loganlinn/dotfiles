{
  bluetooth = ./bluetooth.nix;
  docker = ./docker.nix;
  fonts = ./fonts.nix;
  minecraft-server = ./minecraft-server.nix;
  networking = ./networking;
  nix-path = ./nix-path.nix;
  nix-registry = ../../nix/modules/nix-registry.nix;
  nvidia = ./nvidia.nix;
  pipewire = ./pipewire.nix;
  printing = ./printing;
  security = ./security;
  steam = ./steam.nix;
  tailscale = ./tailscale.nix;
  thunderbolt = ./thunderbolt.nix;
  wayland =  ./wayland.nix;
}
