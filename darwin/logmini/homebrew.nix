{
  homebrew = {
    enable = true;
    brews = [
      "curl"
      "direnv"
      "gh"
      "gnu-getopt"
      "kubernetes-cli"
      "mkcert"
      "nss"
      "tailscale"
    ];
    casks = [
      "1password-cli@beta"
      "discord"
      "orbstack"
      "sf-symbols"
      "vlc"
      # "karabiner-elements"
    ];
  };
}
