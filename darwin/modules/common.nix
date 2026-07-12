{
  self,
  inputs,
  config,
  system,
  pkgs,
  lib,
  ...
}:
with lib; let
  inherit (config) my;
in {
  imports = [
    self.darwinModules.home-manager
    ./system
    ./homebrew.nix
    ./zsh.nix
  ];

  config = {
    assertions = [
      {
        assertion = config.users.users.${my.user.name}.home == "/Users/${my.user.name}";
        message = "check config.my.user.home";
      }
    ];

    users.knownUsers = optional (my.user.uid != null) my.user.name;

    users.users.${my.user.name} =
      {
        inherit
          (my.user)
          description
          shell
          home
          openssh
          ;
        packages =
          my.user.packages
          ++ [
            (pkgs.writeShellScriptBin "editor" ''exec ''${EDITOR:-${pkgs.nano}/bin/nano} "$@"'')
          ];
      }
      // optionalAttrs (my.user.uid != null) {
        inherit (my.user) uid;
      };

    homebrew.enable = mkDefault true;

    # Disable manual/options-doc generation. Building the darwin manual emits an
    # `options.json` derivation that references the flake source path without
    # proper string context, producing a noisy eval warning.
    documentation.enable = mkDefault false;

    fonts.packages = my.fonts.packages;

    environment.variables = my.environment.variables;
    environment.systemPackages = with pkgs; [
      bashInteractive
      pinentry_mac
    ];

    programs.bash = {
      enable = true;
      completion.enable = true;
    };

    programs.zsh = {
      enable = true;
      enableCompletion = mkDefault true;
      enableFzfCompletion = mkDefault true;
      enableFzfHistory = mkDefault true;
      enableSyntaxHighlighting = mkDefault true;
    };

    security = {
      pam.services.sudo_local.touchIdAuth = mkDefault true;
    };

    environment.etc = listToAttrs (
      forEach
      [
        "nixpkgs"
        "nix-darwin"
      ]
      (input: {
        name = "nix/inputs/${input}";
        value = {
          source = "${inputs.${input}}";
        };
      })
    );

    nix.settings =
      my.nix.settings
      // {
        keep-derivations = false;
        auto-optimise-store = false; # https://github.com/NixOS/nix/issues/7273
      };

    nix.registry = my.nix.registry;
  };
}
