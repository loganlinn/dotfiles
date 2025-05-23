{
  description = "loganlinn's systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
    ## builders
    home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:lnl7/nix-darwin";
    # nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    # nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    ## packages
    eww.url = "github:elkowar/eww";
    # eww.inputs.nixpkgs.follows = "nixpkgs";
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
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    # fenix.url = "github:nix-community/fenix";
    # fenix.inputs.nixpkgs.follows = "nixpkgs";
    # rust-overlay.url = "github:oxalica/rust-overlay";
    # rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";

    ## utils
    # _1password-shell-plugins.url = "github:1Password/shell-plugins";
    agenix.url = "github:ryantm/agenix";
    # agenix.inputs.nixpkgs.follows = "nixpkgs";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-root.url = "github:srid/flake-root";
    globset.url = "github:pdtpartners/globset";
    nix-colors.url = "github:misterio77/nix-colors";
    # nix-index-database.url = "github:Mic92/nix-index-database";
    # nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    # nix-topology.url = "github:oddlama/nix-topology";
    # nix-topology.inputs.nixpkgs.follows = "nixpkgs";
    # nixpkgs-match.url = "github:srid/nixpkgs-match";
    # sops-nix.url = "github:Mic92/sops-nix";
    # sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    wezterm.url = "github:wez/wezterm?dir=nix&rev=4accc376f3411f2cbf4f92ca46f79f7bc47688a1";
    # ghostty.url = "github:ghostty-org/ghostty";

    ## srcs
    fzf-tab = {
      url = "github:Aloxaf/fzf-tab";
      flake = false;
    };
    forgit = {
      url = "github:wfxr/forgit";
      flake = false;
    };
    fzf-git-sh = {
      url = "github:junegunn/fzf-git.sh";
      flake = false;
    };
    supermaven-nvim = {
      url = "github:supermaven-inc/supermaven-nvim";
      flake = false;
    };
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
            # (_: super: let pkgs = inputs.fenix.inputs.nixpkgs.legacyPackages.${super.system}; in inputs.fenix.overlays.default pkgs pkgs)
          ];
        };

        packages =
          import ./nix/pkgs {inherit pkgs;}
          // {
            home-manager = inputs'.home-manager.packages.home-manager;
            home-manager-docs-html = inputs'.home-manager.packages.docs-html;
          };

        overlayAttrs = {
          inherit (inputs'.home-manager.packages) home-manager;
          inherit (inputs'.emacs.packages) emacs-unstable;
          inherit (inputs'.agenix.packages) agenix;
          wezterm = inputs'.wezterm.packages.default;
          flake-root = config.flake-root.package;
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
            pkgs.just
            pkgs.age
            pkgs.ssh-to-age
            pkgs.sops
          ];
        };
      };

      flake = let
        inherit (self.lib) mkNixosSystem mkHomeConfiguration mkDarwinSystem;
      in {
        nixosConfigurations.framework = mkNixosSystem "x86_64-linux" ./nixos/framework/configuration.nix;
        nixosConfigurations.nijusan = mkNixosSystem "x86_64-linux" ./nixos/nijusan/configuration.nix;

        darwinConfigurations.patchbook = mkDarwinSystem "aarch64-darwin" ./darwin/patchbook.nix;
        darwinConfigurations.logamma = mkDarwinSystem "aarch64-darwin" ./darwin/logamma;

        homeConfigurations."logan@nijusan" = mkHomeConfiguration "x86_64-linux" ./home-manager/nijusan.nix;
        homeConfigurations."logan@wijusan" = mkHomeConfiguration "x86_64-linux" ./home-manager/wijusan.nix;
      };

      debug = true; # used by mkReplAttrs
    };
}
