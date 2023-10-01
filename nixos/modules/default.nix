{
  _1password = ./1password.nix;
  bluetooth = ./bluetooth.nix;
  common = ./common.nix;
  davfs2 = ./davfs2.nix;
  docker = ./docker.nix;
  gaming = ./gaming.nix;
  hyprland = ./desktops/hyprland;
  minecraft-server = ./minecraft-server.nix;
  networking = ./networking;
  nix-registry = ../../nix/modules/nix-registry.nix;
  nvidia = ./nvidia.nix;
  pipewire = ./pipewire.nix;
  printing = ./printing;
  security = ./security;
  tailscale = ./tailscale.nix;
  thunar = ./thunar.nix;
  thunderbolt = ./thunderbolt.nix;
  wayland = ./wayland.nix;
  xserver = ./xserver.nix;
}
