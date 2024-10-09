{
  description = "loganlinn's systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    ## builders
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    ## packages
    eww.url = "github:elkowar/eww";
    eww.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    git-repo-manager.url = "github:hakoerber/git-repo-manager";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    ## utils
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-root.url = "github:srid/flake-root";
    mission-control.url = "github:Platonic-Systems/mission-control";
    nix-colors.url = "github:misterio77/nix-colors";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-match.url = "github:srid/nixpkgs-match";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://loganlinn.cachix.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "loganlinn.cachix.org-1:CsnLzdY/Z5Btks1lb9wpySLJ60+H9kwFVbcQeb2Pjf8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-module
        flake-parts.flakeModules.easyOverlay
        inputs.flake-root.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        ctx@{
          inputs',
          self',
          config,
          system,
          pkgs,
          lib,
          ...
        }:
        {
          imports = [ ./options.nix ];

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config = import ./config/nixpkgs/config.nix;
            overlays = [
              self.overlays.default
              # TODO: use overlay conditionally, i.e. https://github.com/hlissner/dotfiles/blob/1e2ca74b02d2d92005352bf328acc86abb10efbd/modules/editors/emacs.nix#L28-L31
              inputs.emacs-overlay.overlays.default
              inputs.git-repo-manager.overlays.git-repo-manager
              inputs.fenix.overlays.default
            ];
          };

          packages = import ./nix/pkgs { inherit pkgs; };

          apps = {
            default = {
              type = "app";
              program = "${pkgs.cowsay}/bin/cowsay";
            };

            nixpkgs-match = {
              type = "app";
              program = ''nix run github:srid/nixpkgs-match -- "$@"'';
            };
          };

          overlayAttrs = {
            inherit (inputs'.home-manager.packages) home-manager;
            inherit (inputs'.devenv.packages) devenv;
            inherit (inputs'.emacs.packages) emacs-unstable;
            inherit (inputs'.agenix.packages) agenix;
          };

          formatter = pkgs.nixpkgs-fmt;

          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.flake-root.devShell # sets FLAKE_ROOT
              config.mission-control.devShell
            ];
            nativeBuildInputs = [
              config.formatter
              inputs'.agenix.packages.agenix
              pkgs.just
              pkgs.age
              pkgs.ssh-to-age
              pkgs.sops
            ];
          };

          legacyPackages = lib.optionalAttrs (ctx.system == "x86_64-linux") {
            homeConfigurations = {
              "logan@nijusan" = self.lib.mkHomeConfiguration ctx [
                self.homeModules.common
                self.homeModules.nix-colors
                self.homeModules.secrets
                ./home-manager/nijusan.nix
              ];
              "logan@wijusan" = self.lib.mkHomeConfiguration ctx [
                self.homeModules.common
                self.homeModules.nix-colors
                self.homeModules.secrets
                ./home-manager/wijusan.nix
              ];
            };
          };
        };

      flake = {
        nixosConfigurations.nijusan = self.lib.mkNixosSystem "x86_64-linux" [
          ./nixos/nijusan/configuration.nix
        ];

        nixosConfigurations.framework = self.lib.mkNixosSystem "x86_64-linux" [
          ./nixos/framework/configuration.nix
        ];

        nixosConfigurations.juuni = self.lib.mkNixosSystem "x86_64-linux" [
          ./nixos/juuni/configuration.nix
        ];

        darwinConfigurations.patchbook = self.lib.mkDarwinSystem "aarch64-darwin" [
          ./darwin/patchbook.nix
        ];

        darwinConfigurations.logamma = self.lib.mkDarwinSystem "aarch64-darwin" [
          ./darwin/logamma
        ];
      };

      # my repl depends on attrs exposed by flake-parts's debug option.
      # https://flake.parts/debug.html
      # https://flake.parts/options/flake-parts.html#opt-debug
      debug = true;
    };
}
