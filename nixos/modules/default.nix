{
  bluetooth = ./bluetooth.nix;
  docker = ./docker.nix;
  minecraft-server = ./minecraft-server.nix;
  networking = ./networking;
  nix-registry = ../../nix/modules/nix-registry.nix;
  nvidia = ./nvidia.nix;
  pipewire = ./pipewire.nix;
  printing = ./printing;
  security = ./security;
  steam = ./steam.nix;
  tailscale = ./tailscale.nix;
  thunar = ./thunar.nix;
  thunderbolt = ./thunderbolt.nix;
  wayland =  ./wayland.nix;
}
