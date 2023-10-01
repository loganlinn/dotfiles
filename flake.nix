{
  description = "loganlinn's (highly indecisive) flake";

  inputs = {
    ## packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    hyprland-plugins.inputs.hyprland.follows = "hyprland";
    eww.url = "github:elkowar/eww";
    eww.inputs.nixpkgs.follows = "nixpkgs";

    ## builders
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    ## overlays
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    ## etc
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root = { url = "github:srid/flake-root"; };
    mission-control = { url = "github:Platonic-Systems/mission-control"; };
    nix-colors = { url = "github:misterio77/nix-colors"; };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-match.url = "github:srid/nixpkgs-match";
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
        ./mission-control.nix
        ./flake-module.nix
      ];

      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = ctx@{ inputs', self', config, system, pkgs, lib, ... }: {
        imports = [ ./options.nix ];

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = import ./config/nixpkgs/config.nix;
        };

        packages = import ./nix/pkgs { inherit pkgs; };

        apps.default = {
          type = "app";
          program = "${pkgs.cowsay}/bin/cowsay";
        };

        apps.rebuild = {
          type = "app";
          program = pkgs.writeShellApplication {
            name = "rebuild";
            runtimeInputs = with pkgs; [ ansi gum nvd ];
            text = ''
              _run() {
                ansi -e yellow
                printf '$ %s\n\n' "$*"
                ansi -e reset

                if "$@"; then
                  true
                else
                  local status=$?
                  ansi -e red
                  echo "command failed (exit=$status)"
                  ansi -e reset
                  return "$status"
                fi
              }

              _sudo() {
                if [[ $EUID == 0 ]]; then
                  _run env "$@"
                else
                  _run sudo "$@"
                fi
              }

              # Pass-through
              if [[ $(uname -s) == "Darwin" ]]; then
                exec darwin-rebuild "$@"
              elif (( $# )); then
                _run nixos-rebuild "$@"
                exit "$?"
              fi;


              build() {
                local choices=( "build" )

                if _run nixos-rebuild build "$@" &&
                  _run nvd diff /run/current-system result; then
                  choices+=(
                    switch
                    boot
                    test
                    dry-activate
                    build-vm
                    build-vm-with-bootloader
                    edit
                    exit
                  )
                fi

                if action=$(gum choose --header "nixos-rebuild operation:" "''${choices[@]}"); then
                  case "$action" in
                    build) build "$@";;
                    exit) exit;;
                    *) _sudo nixos-rebuild "$action" "$@";;
                  esac
                else
                  ansi -e yellow
                  echo 'aborted.'
                  ansi -e reset
                fi
              }

              build "$@"
            '';
          };
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

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            config.flake-root.devShell # sets FLAKE_ROOT
            config.mission-control.devShell
          ];
          buildInputs = [ config.formatter inputs'.agenix.packages.agenix ];
          env.NIX_USER_CONF_FILES = toString ./nix.conf;
        };

        # FIXME: there's probably a flake.parts facility for this
        legacyPackages = lib.optionalAttrs (ctx.system == "x86_64-linux") {
          homeConfigurations = {
            "logan@nijusan" = self.lib.dotfiles.mkHomeConfiguration ctx {
              imports = [
                self.homeModules.common
                self.homeModules.nix-colors
                self.homeModules.secrets
                ./home-manager/nijusan.nix
              ];
            };
          };
        };
      };

      flake = {
        nixosConfigurations.nijusan =
          self.lib.dotfiles.mkNixosSystem "x86_64-linux" [
            ./nixos/nijusan/configuration.nix
            inputs.home-manager.nixosModules.home-manager
            self.nixosModules.home-manager
          ];

        nixosConfigurations.framework =
          self.lib.dotfiles.mkNixosSystem "x86_64-linux" [
            ./nixos/framework/configuration.nix
            inputs.home-manager.nixosModules.home-manager
            inputs.agenix.nixosModules.default
            self.nixosModules.home-manager
            # { home-manager.users.logan = import ./nixos/framework/home.nix; }
          ];

        darwinConfigurations.patchbook =
          self.lib.dotfiles.lib.mkMacosSystem "aarch64-darwin" [
            self.darwinModules.home-manager
            ./nix-darwin/patchbook.nix
            {
              home-manager.users.logan = { options, config, ... }: {
                imports = [ self.homeModules.default ];
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
