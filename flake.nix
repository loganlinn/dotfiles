{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    # TODO: remove fork once https://github.com/nix-darwin/nix-darwin/pull/1789 is merged
    nix-darwin.url = "github:loganlinn/nix-darwin/homebrew-trust";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    comfyui-nix.url = "github:utensils/comfyui-nix";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-lsp-booster.url = "github:slotThe/emacs-lsp-booster-flake";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    globset.url = "github:pdtpartners/globset";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    nix-colors.url = "github:misterio77/nix-colors";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    opnix.inputs.nixpkgs.follows = "nixpkgs";
    opnix.url = "github:brizzbuzz/opnix";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    supermaven-nvim.flake = false;
    supermaven-nvim.url = "github:supermaven-inc/supermaven-nvim";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib.url = "github:hyprwm/contrib";
    hyprland-contrib.inputs.nixpkgs.follows = "hyprland/nixpkgs";
    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    hyprland-plugins.inputs.hyprland.follows = "hyprland";
    hypridle.url = "github:hyprwm/hypridle";
    hypridle.inputs.hyprlang.follows = "hyprland/hyprlang";
    hypridle.inputs.hyprutils.follows = "hyprland/hyprutils";
    hypridle.inputs.nixpkgs.follows = "hyprland/nixpkgs";
    hypridle.inputs.systems.follows = "hyprland/systems";
    hyprlock.url = "github:hyprwm/hyprlock";
    hyprlock.inputs.hyprgraphics.follows = "hyprland/hyprgraphics";
    hyprlock.inputs.hyprlang.follows = "hyprland/hyprlang";
    hyprlock.inputs.hyprutils.follows = "hyprland/hyprutils";
    hyprlock.inputs.nixpkgs.follows = "hyprland/nixpkgs";
    hyprlock.inputs.systems.follows = "hyprland/systems";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpaper.inputs.hyprgraphics.follows = "hyprland/hyprgraphics";
    hyprpaper.inputs.hyprlang.follows = "hyprland/hyprlang";
    hyprpaper.inputs.hyprutils.follows = "hyprland/hyprutils";
    hyprpaper.inputs.nixpkgs.follows = "hyprland/nixpkgs";
    hyprpaper.inputs.systems.follows = "hyprland/systems";
    quickshell.url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./flake-module
        flake-parts.flakeModules.easyOverlay
        inputs.flake-root.flakeModule
        inputs.home-manager.flakeModules.home-manager
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = ctx @ {
        inputs',
        self',
        config,
        system,
        pkgs,
        lib,
        ...
      }: {
        imports = [./options.nix];

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = import ./config/nixpkgs/config.nix;
          overlays = [
            self.overlays.default
            inputs.emacs-overlay.overlays.default
            inputs.emacs-lsp-booster.overlays.default
          ];
        };

        packages = import ./nix/pkgs {inherit inputs' pkgs;};

        overlayAttrs = {
          inherit (inputs'.home-manager.packages) home-manager;
          inherit (inputs'.emacs.packages) emacs-unstable;
          fzf-git-sh = pkgs.fzf-git-sh.overrideAttrs (prev: {
            version = inputs.fzf-git-sh.shortRev;
            src = inputs.fzf-git-sh;
          });
          less = pkgs.less.overrideAttrs (_: {
            version = "692";
            src = pkgs.fetchurl {
              url = "https://www.greenwoodsoftware.com/less/less-692.tar.gz";
              hash = "sha256-YTAPYDeY7PHXeGVweJ8P8/WhrPB1pvufdWg30WbjfRQ=";
            };
          });
        };

        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.flake-root.devShell # sets FLAKE_ROOT
          ];
          nativeBuildInputs = [
            pkgs.bashInteractive
            config.formatter
            inputs'.home-manager.packages.home-manager
            inputs'.opnix.packages.default
            pkgs.age
            pkgs.just
            pkgs.sops
            pkgs.ssh-to-age
          ];
        };
      };

      flake = let
        inherit (self.lib) mkNixosSystem mkHomeConfiguration mkDarwinSystem;
      in {
        nixosConfigurations = {
          framework = mkNixosSystem {
            system = "x86_64-linux";
            modules = [./nixos/framework/configuration.nix];
          };
          nijusan = mkNixosSystem {
            system = "x86_64-linux";
            modules = [./nixos/nijusan/configuration.nix];
          };

          logamma = mkNixosSystem {
            system = "aarch64-linux";
            modules = [];
          };
          orbstack = mkNixosSystem {
            system = "aarch64-linux";
            modules = [./nixos/orbstack/configuration.nix];
          };
        };

        darwinConfigurations = {
          patchbook = mkDarwinSystem {
            system = "aarch64-darwin";
            modules = [./darwin/patchbook.nix];
          };
          logamma = mkDarwinSystem {
            system = "aarch64-darwin";
            modules = [./darwin/logamma];
          };
          logmini = mkDarwinSystem {
            system = "aarch64-darwin";
            modules = [./darwin/logmini];
          };
        };

        homeConfigurations = {
          "logan@framework" = mkHomeConfiguration {
            system = "x86_64-linux";
            modules = [./home-manager/framework.nix];
          };
          "logan@nijusan" = mkHomeConfiguration {
            system = "x86_64-linux";
            modules = [./home-manager/nijusan.nix];
          };
          "logan@wijusan" = mkHomeConfiguration {
            system = "x86_64-linux";
            modules = [./home-manager/wijusan.nix];
          };
        };
      };

      debug = true; # used by mkReplAttrs
    };
}
