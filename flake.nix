{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";

    ## builders
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## packages
    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    git-repo-manager = {
      url = "github:hakoerber/git-repo-manager";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## utils
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root = {
      url = "github:srid/flake-root";
    };
    mission-control = {
      url = "github:Platonic-Systems/mission-control";
    };
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-match.url = "github:srid/nixpkgs-match";
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
    inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
        ./mission-control.nix
        ./flake-module.nix
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
        }: {
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

          apps.default = {
            type = "app";
            program = "${pkgs.cowsay}/bin/cowsay";
          };

          apps.nixpkgs-match = {
            type = "app";
            program = ''nix run github:srid/nixpkgs-match -- "$@"'';
          };

          overlayAttrs = {
            inherit (inputs'.home-manager.packages) home-manager;
            inherit (inputs'.devenv.packages) devenv;
            inherit (inputs'.emacs.packages) emacs-unstable;
            inherit (inputs'.agenix.packages) agenix;
          };

          formatter = pkgs.nixpkgs-fmt;

          devShells =
            {
              default = pkgs.mkShell {
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
                env.NIX_USER_CONF_FILES = toString ./nix.conf;
              };
            }
            // (lib.listToAttrs (
              lib.forEach
                [
                  "stable"
                  "beta"
                  "minimal"
                  "default"
                  "complete"
                  "latest"
                ]
                (toolchain: {
                  name = "rust-${toolchain}";
                  value = pkgs.mkShell {
                    buildInputs = with pkgs; [
                      cmake
                      llvmPackages.bintools
                      openssl
                      pkg-config
                      # (rust-bin.stable.latest.default.override {
                      #   targets = [ "wasm32-unknown-unknown" ];
                      # })
                      (fenix."${toolchain}".withComponents [
                        # https://rust-lang.github.io/rustup/concepts/components.html
                        "cargo"
                        "clippy"
                        "rust-docs"
                        "rust-src"
                        "rustc"
                        "rustfmt"
                      ])
                      rust-analyzer-nightly
                    ];
                  };
                })
            ));

          legacyPackages = lib.optionalAttrs (ctx.system == "x86_64-linux") {
            homeConfigurations = {
              "logan@nijusan" = self.lib.dotfiles.mkHomeConfiguration ctx [
                self.homeModules.common
                self.homeModules.nix-colors
                self.homeModules.secrets
                ./home-manager/nijusan.nix
              ];
              "logan@wijusan" = self.lib.dotfiles.mkHomeConfiguration ctx [
                self.homeModules.common
                self.homeModules.nix-colors
                self.homeModules.secrets
                ./home-manager/wijusan.nix
              ];
            };
          };
        };

      flake = {
        nixosConfigurations.nijusan = self.lib.dotfiles.mkNixosSystem "x86_64-linux" [
          ./nixos/nijusan/configuration.nix
          # self.nixosModules.home-manager
        ];

        nixosConfigurations.framework = self.lib.dotfiles.mkNixosSystem "x86_64-linux" [
          inputs.agenix.nixosModules.default
          inputs.nixvim.nixosModules.nixvim
          ./nixos/framework/configuration.nix
          ./nix/modules/programs/nixvim
          self.nixosModules.home-manager
          {
            home-manager.users.logan = import ./nixos/framework/home.nix; # TODO unify with nijusan
            programs.nixvim.enable = true;
            programs.nixvim.defaultEditor = true;
          }
        ];

        nixosConfigurations.wijusan = self.lib.dotfiles.mkNixosSystem "x86_64-linux" [
          ./nixos/wijusan/configuration.nix
        ];

        darwinConfigurations.patchbook = self.lib.dotfiles.mkDarwinSystem "aarch64-darwin" [
          self.darwinModules.common
          self.darwinModules.home-manager
          ./nix-darwin/patchbook.nix
          {
            home-manager.users.logan =
              { options, config, ... }:
              {
                imports = [
                  self.homeModules.common
                  self.homeModules.nix-colors
                  ./nix/home/dev
                  ./nix/home/pretty.nix
                ];
                home.stateVersion = "22.11";
              };
          }
        ];
      };

      # my repl depends on attrs exposed by flake-parts's debug option.
      # https://flake.parts/debug.html
      # https://flake.parts/options/flake-parts.html#opt-debug
      debug = true;
    };
}
