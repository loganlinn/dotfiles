{ lib, ... }: {
  homebrew = {
    taps =
      lib.map
        (tap: {
          name = tap;
          trusted = true;
          force_auto_update = true;
        })
        [
          # "abhinav/tap"
          # "anthropics/tap"
          # "aws/tap"
          # "bridgecrewio/tap"
          "buildkite/buildkite"
          "charmbracelet/tap"
          # "dagger/tap"
          # "keith/formulae"
          "localstack/tap"
          # "minamijoyo/hcledit"
          # "minamijoyo/tfmigrate"
          "minamijoyo/tfschema"
          # "minamijoyo/tfupdate"
          "pulumi/tap"
          "tsonglew/dutis"
          "withgraphite/tap"
          # "wedow/tools"
        ];
    brews = [
      {
        name = "postgresql@16";
        link = true;
      }
      # "anthropics/tap/ant"
      "aspell"
      "docker-credential-helper-ecr"
      "buildkite/buildkite/bk@3"
      "caddy"
      "charmbracelet/tap/freeze"
      "charmbracelet/tap/sequin"
      # "colima" # TODO: use https://github.com/nix-community/home-manager/blob/master/modules/services/colima.nix ?
      "curl"
      # "ddcctl"
      "direnv"
      "duti"
      "gh"
      "gnu-getopt"
      # "grafana"
      # "hcledit"
      "hex-inc/hex-cli/hex"
      # "incus"
      # "inframap"
      "kubernetes-cli"
      # "ldcli"
      "llama.cpp"
      "localstack/tap/localstack-cli"
      "luarocks"
      # "mas"
      # "minamijoyo/hcledit/hcledit"
      # "minamijoyo/tfmigrate/tfmigrate"
      "minamijoyo/tfschema/tfschema"
      # "minamijoyo/tfupdate/tfupdate"
      "mkcert"
      "nss"
      "ollama"
      "redis"
      "tfenv"
      "tsonglew/dutis/dutis"
      "withgraphite/tap/graphite"
    ];
    casks = [
      "1password-cli@beta"
      "discord"
      "ghostty"
      "hammerspoon"
      "jordanbaird-ice"
      "nikitabobko/tap/aerospace"
      "orbstack"
      "pearcleaner"
      "sf-symbols"
      "tailscale-app"
      "temurin@17"
      "vlc"
      # "inkscape"
      # "obs"
      # "visualvm"
      # "1password" # currently installed manually
      # "dbeaver-community"
      # "gimp"
      # "karabiner-elements"
    ];
  };
}
