{
  fonts = import ./fonts.nix;
  minecraft-server = import ./minecraft-server.nix;
  nix-path = import ./nix-path.nix;
  steam = import ./steam.nix;
  tailscale = import ./tailscale.nix;
  thunar = import ./thunar.nix;
  wayland =  import ./wayland.nix;
}
