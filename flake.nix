{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # claude-desktop.inputs.flake-utils.follows = "flake-utils";
    # claude-desktop.inputs.nixpkgs.follows = "nixpkgs";
    # claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    globset.url = "github:pdtpartners/globset";
    nix-colors.url = "github:misterio77/nix-colors";
    nixvim.url = "github:nix-community/nixvim";
    opnix.inputs.nixpkgs.follows = "nixpkgs";
    opnix.url = "github:brizzbuzz/opnix";
    supermaven-nvim.flake = false;
    supermaven-nvim.url = "github:supermaven-inc/supermaven-nvim";
    # wezterm.inputs.nixpkgs.follows = "nixpkgs";
    # wezterm.url = "github:wez/wezterm?dir=nix&rev=4accc376f3411f2cbf4f92ca46f79f7bc47688a1";

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

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-module
        flake-parts.flakeModules.easyOverlay
        inputs.flake-root.flakeModule
        inputs.home-manager.flakeModules.home-manager
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
              inputs.emacs-overlay.overlays.default
            ];
          };

          packages = import ./nix/pkgs { inherit pkgs; };

          overlayAttrs = {
            inherit (inputs'.home-manager.packages) home-manager;
            inherit (inputs'.emacs.packages) emacs-unstable;
            inherit (inputs'.agenix.packages) agenix;
            fzf-git-sh = pkgs.fzf-git-sh.overrideAttrs (prev: {
              version = inputs.fzf-git-sh.shortRev;
              src = inputs.fzf-git-sh;
            });
          };

          formatter = pkgs.alejandra;

          devShells.default = pkgs.mkShell {
            inputsFrom = [
              config.flake-root.devShell # sets FLAKE_ROOT
            ];
            nativeBuildInputs = [
              config.formatter
              inputs'.agenix.packages.agenix
              inputs'.home-manager.packages.home-manager
              inputs'.opnix.packages.default
              pkgs.age
              pkgs.just
              pkgs.sops
              pkgs.ssh-to-age
            ];
          };
        };

      flake =
        let
          inherit (self.lib) mkNixosSystem mkHomeConfiguration mkDarwinSystem;
        in
        {
          nixosConfigurations.framework = mkNixosSystem {
            system = "x86_64-linux";
            modules = [ ./nixos/framework/configuration.nix ];
          };

          nixosConfigurations.nijusan = mkNixosSystem {
            system = "x86_64-linux";
            modules = [ ./nixos/nijusan/configuration.nix ];
          };

          darwinConfigurations.patchbook = mkDarwinSystem {
            system = "aarch64-darwin";
            modules = [ ./darwin/patchbook.nix ];
          };

          darwinConfigurations.logamma = mkDarwinSystem {
            system = "aarch64-darwin";
            modules = [ ./darwin/logamma ];
          };

          homeConfigurations."logan@nijusan" = mkHomeConfiguration {
            system = "x86_64-linux";
            modules = [ ./home-manager/nijusan.nix ];
          };
          homeConfigurations."logan@wijusan" = mkHomeConfiguration {
            system = "x86_64-linux";
            modules = [ ./home-manager/wijusan.nix ];
          };
        };

      debug = true; # used by mkReplAttrs
    };
}
