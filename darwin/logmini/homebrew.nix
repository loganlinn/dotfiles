{lib, ...}: {
  homebrew = {
    enable = true;
    taps =
      lib.map
      (tap: {
        name = tap;
        trusted = true;
        force_auto_update = true;
      })
      [
        "withgraphite/tap"
      ];
    brews = [
      "curl"
      "direnv"
      "gh"
      "gnu-getopt"
      "kubernetes-cli"
      "mkcert"
      "nss"
      "tailscale"
      "withgraphite/tap/graphite"
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
