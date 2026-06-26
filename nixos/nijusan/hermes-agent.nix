{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  sops.secrets = {
    hermesEnvironmentFile = {
      sopsFile = ../../secrets/hermes.env;
      format = "dotenv";
    };
    hermesAuthFile = {
      sopsFile = ../../secrets/hermes.auth.json;
      format = "json";
    };
  };

  services.caddy = lib.mkIf config.services.hermes-agent.enable {
    virtualHosts."dashboard.hermes.nijusan.internal" = {
      serverAliases = [
        "dashboard.hermes.nijusan.local"
        "dashboard.hermes.local"
        "dashboard.hermes.internal"
      ];
      extraConfig = ''
        # .internal is not a public TLD, so ACME can't issue a cert.
        # Use Caddy's local CA to serve HTTPS with a self-signed cert.
        tls internal
        handle {
          reverse_proxy 127.0.0.1:9119
        }
      '';
    };
  };

  services.hermes-agent = {
    enable = false;
    addToSystemPackages = true;
    environmentFiles = [config.sops.secrets.hermesEnvironmentFile.path];
    environment = {
      AGENT_BROWSER_EXECUTABLE_PATH = "${lib.getExe pkgs.google-chrome}";
    };
    # authFile = config.sops.secrets.hermesAuthFile.path;
    settings = {
      model = {
        provider = "nous";
        default = "deepseek/deepseek-v4-pro";
      };
      # model = {
      #   provider = "anthropic";
      #   default = "anthropic/claude-opus-4-8";
      # };
      toolsets = ["all"];
      terminal = {
        backend = "local";
        timeout = 180;
      };
      plugins.enabled = [
        # "hermes-lcm"
        # "rtk-rewrite"
      ];
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };
    };
    extraDependencyGroups = [
      "anthropic"
      "honcho"
      "hindsight"
      "messaging"
    ];
    extraPlugins = [
      # (pkgs.fetchFromGitHub {
      #   owner = "stephenschoettler";
      #   repo = "hermes-lcm";
      #   rev = "a426c97fd183af62bedf83fc0606ea35e666f7bb";
      #   hash = "sha256-YWiCAqEhhc9C8SSe5TWE7XqPlm7MkaW9WUd93Om7wdA=";
      # })
    ];
    extraPythonPackages = [
      # (pkgs.python312Packages.buildPythonPackage {
      #   pname = "rtk-hermes";
      #   version = "1.0.0";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "ogallotti";
      #     repo = "rtk-hermes";
      #     rev = "da69176dc0543b8934998ba74f3403cd28f57764";
      #     hash = "sha256-7YRW6PODrCapfYLFn3DvgHAEME//RGC48GQt+s9ot0s=";
      #   };
      # })
    ];
    extraPackages = with pkgs; [
      age
      as-tree
      bat
      bc
      binutils
      bkt
      cmake
      coreutils-full
      curl
      dig
      direnv
      doggo
      dua
      duf
      dust
      envsubst
      file
      fzf
      gawk
      gh
      git
      gnugrep
      gnumake
      gnused
      gnutar
      gnutls
      gnupg
      gzip
      imagemagick
      inetutils
      jq
      lsof
      moreutils
      pandoc
      repgrep
      ripgrep
      rlwrap
      sd
      sops
      stow
      tre-command
      tree
      trurl
      unzip
      wget
      xh
      zip
    ];
    mcpServers = {
      context7 = {
        url = "https://mcp.context7.com/mcp";
        headers = {
          Authorization = "Bearer \${CONTEXT7_API_KEY}";
        };
      };
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        args = [];
      };
    };
  };

  # systemd.services.hermes-agent-dashboard = {
  #   description = "Hermes Agent Web Dashboard";
  #   after = [
  #     "network-online.target"
  #     "hermes-agent.service"
  #   ];
  #   wants = [ "network-online.target" ];
  #   requires = [ "hermes-agent.service" ];
  #   wantedBy = [ "multi-user.target" ];
  #   environment = config.hermes-agent.environment
  #   environment = config.hermes-agent.environment
  #   path = [
  #     config.services.hermes-agent.package
  #   ];
  #   serviceConfig = {
  #     User = config.services.hermes-agent.user;
  #     Group = config.services.hermes-agent.group;
  #     WorkingDirectory = config.services.hermes-agent.workingDirectory;
  #     ExecStart = "${config.services.hermes-agent.package}/bin/hermes dashboard --no-open --host 127.0.0.1 --port 9119";
  #     Restart = "always";
  #     RestartSec = 5;
  #     Environment = [
  #       "HOME=/home/logan"
  #       "HERMES_HOME=${config.services.hermes-agent.stateDir}/.hermes"
  #       "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/logan/bin"
  #     ];
  #     ReadWritePaths = [
  #       config.services.hermes-agent.stateDir
  #       config.services.hermes-agent.workingDirectory
  #     ];
  #   };
  # };

  # users.users.${config.my.user.name}.extraGroups = [
  #   "hermes" # share hermes-agent stateDir (/var/lib/hermes/.hermes, mode 2770)
  # ];
}
