{
  description = "loganlinn's (highly indecisive) flake";

  inputs = {
    ## packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    ## builders
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    hyprland-plugins.inputs.hyprland.follows = "hyprland";
    # nixos-shell.url = "github:Mic92/nixos-shell";
    # nixinate.url = "github:matthewcroughan/nixinate";

    ## overlays
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    eww.url = "github:elkowar/eww";
    eww.inputs.nixpkgs.follows = "nixpkgs";
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    # nixgl.url = "github:guibou/nixGL";

    ## utils
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs"; };
    flake-root = { url = "github:srid/flake-root"; };
    mission-control = { url = "github:Platonic-Systems/mission-control"; };
    nix-colors = { url = "github:misterio77/nix-colors"; };
    agenix = { url = "github:ryantm/agenix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-index-database = { url = "github:Mic92/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; };
    devenv = { url = "github:cachix/devenv"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs-match.url = "github:srid/nixpkgs-match";
  };

  outputs = inputs @ { self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
        ./flake-module.nix
      ];

      # repl depends on attrs exposed by flake-parts's debug option.
      # https://flake.parts/debug.html
      # https://flake.parts/options/flake-parts.html#opt-debug
      debug = true;

      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = ctx@{ inputs', self', config, system, pkgs, lib, ... }: {
        packages = (import ./nix/pkgs pkgs) // {
          jdk = lib.mkDefault pkgs.jdk; # needed?
        };

        overlayAttrs = {
          inherit (config.packages) jdk kubefwd i3-auto-layout;
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
          buildInputs = [
            config.formatter
            inputs'.agenix.packages.agenix
          ];
          env.NIX_USER_CONF_FILES = toString ./nix.conf;
        };

        mission-control = {
          wrapperName = ",,"; # play nice with nix-community/comma
          scripts =
            let
              inherit (lib) getExe;
              withPrintNixEnv = cmd: ''printenv | grep '^NIX'; ${cmd}'';
              withCows = cmd: ''${pkgs.neo-cowsay}/bin/cowsay --random -- ${lib.escapeShellArg cmd}; ${cmd}'';
              replExec = f: withPrintNixEnv (withCows ''
                nix repl --verbose --trace-verbose --file "${f}" "$@"
              '');
            in
            {
              z = {
                description = "Start flake REPL";
                exec = replExec "repl.nix";
              };
              b = {
                description = "Build configuration";
                exec = ''home-manager build --flake "$@"'';
              };
              s = {
                description = "Build + activate configuration";
                exec = withCows "home-manager switch --flake ~/.";
              };
              f = {
                description = "Run nix fmt";
                exec = "nix fmt";
              };
              hm = {
                description = "Run home-manager";
                exec = getExe inputs'.home-manager.packages.home-manager;
              };
              zh = {
                description = "Start home-manger REPL";
                exec = replExec "home-manager/repl.nix";
              };
              zo = {
                description = "Start nixos REPL";
                exec = replExec "nixos/repl.nix";
              };
              up = {
                description = "Update flake.lock";
                exec = ''nix flake update --commit-lock-file "$@"'';
              };
              show = {
                description = "Show flake outputs";
                exec = ''nix flake show "$@"'';
              };
              meta = {
                description = "Show flake";
                exec = ''nix flake metadata "$@"'';
              };
            };
        };

        # FIXME: there's probably a flake.parts facility for this
        legacyPackages = lib.optionalAttrs (ctx.system == "x86_64-linux") {
          homeConfigurations = {
            "logan@nijusan" = self.lib.dotfiles.mkHomeConfiguration ctx {
              imports = [
                self.homeModules.common
                self.homeModules.secrets
                ./home-manager/nijusan.nix
              ];
            };
          };
        };
      };

      flake = {
        nixosConfigurations = {
          nijusan = self.lib.dotfiles.mkNixosSystem "x86_64-linux" {
            imports = [
              ./nixos/nijusan/configuration.nix
            ];
          };
          framework= self.lib.dotfiles.mkNixosSystem "x86_64-linux" {
            imports = [
              self.nixosModules.common
              self.nixosModules.home-manager
              ./nixos/framework/configuration.nix
            ];
          };
        };

        darwinConfigurations.patchbook = self.lib.dotfiles.lib.mkMacosSystem "aarch64-darwin" {
          imports = [
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
      };
    };
}
