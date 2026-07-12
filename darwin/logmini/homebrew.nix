{ lib, ... }: {
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
          "charmbracelet/tap"
          "withgraphite/tap"
        ];
    brews = [
      "charmbracelet/tap/freeze"
      "charmbracelet/tap/sequin"
      "curl"
      "direnv"
      "gh"
      "gnu-getopt"
      "kubernetes-cli"
      "libvterm"
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
