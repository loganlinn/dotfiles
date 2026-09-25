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
  };

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    environmentFiles = [config.sops.secrets.hermesEnvironmentFile.path];
    settings = {
      model = {
        provider = "nous";
        default = "deepseek/deepseek-v4-pro";
      };
      toolsets = ["all"];
      terminal = {
        backend = "local";
        timeout = 180;
      };
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
    extraPackages = with pkgs; [
      age
      as-tree
      bat
      coreutils-full
      curl
      direnv
      file
      fzf
      gawk
      gh
      git
      gnugrep
      gnupg
      gnused
      gnutar
      jq
      moreutils
      repgrep
      ripgrep
      sd
      sops
      tree
      unzip
      wget
      zip
    ];
    mcpServers = {
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
        args = [];
      };
    };
  };
}
