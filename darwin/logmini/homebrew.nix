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
          # "anthropics/tap"
          # "aws/tap"
          # "charmbracelet/tap"
          # "tsonglew/dutis"
          "withgraphite/tap"
        ];
    brews = [
      # "anthropics/tap/ant"
      # "caddy"
      # "charmbracelet/tap/freeze"
      # "charmbracelet/tap/sequin"
      "curl"
      "direnv"
      # "duti"
      "gh"
      "gnu-getopt"
      # "grafana"
      "kubernetes-cli"
      "libvterm"
      # "llama.cpp"
      # "luarocks"
      # "mas"
      "mkcert"
      "nss"
      # "ollama"
      "tailscale"
      # "tsonglew/dutis/dutis"
      "withgraphite/tap/graphite"
    ];
    casks = [
      "1password-cli@beta"
      # "discord"
      # "jordanbaird-ice"
      "orbstack"
      # "pearcleaner"
      # "sf-symbols"
      "vlc"
      # "inkscape"
      # "obs"
      # "karabiner-elements"
    ];
  };
}
