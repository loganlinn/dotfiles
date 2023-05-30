{
  fonts = import ./fonts.nix;
  minecraft-server = import ./minecraft-server.nix;
  steam = import ./steam.nix;
  tailscale = import ./tailscale.nix;
  thunar = import ./thunar.nix;
  wayland =  import ./wayland.nix;
}
