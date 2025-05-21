{
  description = "loganlinn's systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    ## builders
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    ## packages
    eww.url = "github:elkowar/eww";
    # eww.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.hyprlang.follows = "hyprland/hyprlang";
      inputs.hyprutils.follows = "hyprland/hyprutils";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
      inputs.systems.follows = "hyprland/systems";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.hyprgraphics.follows = "hyprland/hyprgraphics";
      inputs.hyprlang.follows = "hyprland/hyprlang";
      inputs.hyprutils.follows = "hyprland/hyprutils";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
      inputs.systems.follows = "hyprland/systems";
    };
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.hyprgraphics.follows = "hyprland/hyprgraphics";
      inputs.hyprlang.follows = "hyprland/hyprlang";
      inputs.hyprutils.follows = "hyprland/hyprutils";
      inputs.nixpkgs.follows = "hyprland/nixpkgs";
      inputs.systems.follows = "hyprland/systems";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    betterfox = {
      url = "github:yokoffing/Betterfox";
      flake = false;
    };
    thunderbird-catppuccin = {
      url = "github:catppuccin/thunderbird";
      flake = false;
    };
    zen-browser = {
      url = "github:maximoffua/zen-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## utils
    # _1password-shell-plugins.url = "github:1Password/shell-plugins";
    agenix.url = "github:ryantm/agenix";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    globset.url = "github:pdtpartners/globset";
    nix-colors.url = "github:misterio77/nix-colors";
    wezterm.url = "github:wez/wezterm?dir=nix&rev=4accc376f3411f2cbf4f92ca46f79f7bc47688a1";

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

  outputs =
    inputs@{ self, flake-parts, ... }:
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
              # (_: super: let pkgs = inputs.fenix.inputs.nixpkgs.legacyPackages.${super.system}; in inputs.fenix.overlays.default pkgs pkgs)
            ];
          };

          packages = import ./nix/pkgs { inherit pkgs; } // {
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

          formatter = pkgs.nixpkgs-fmt;

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

      flake =
        let
          inherit (self.lib)
            mkNixosSystem'
            mkNixosSystem
            mkHomeConfiguration
            mkDarwinSystem
            ;
        in
        {
          nixosConfigurations.framework =
            mkNixosSystem' "x86_64-linux" ./nixos/hosts/framework/configuration.nix
              {
                inherit self;
                outputs = self.outputs;
                inputs = self.inputs;
                username = "logan";
                editor = "nixvim";
                browser = "floorp";
                terminal = "wezterm";
                terminalFileManager = "yazi";
                sddmTheme = "purple_leaves";
                wallpaper = "kurzgesagt";
                hostname = "framework";
                locale = "en_US.UTF-8";
                timezone = "America/Los_Angeles";
                kbdLayout = "us";
                kbdVariant = "";
                consoleKeymap = "us";
              };

          nixosConfigurations.nijusan = mkNixosSystem "x86_64-linux" ./nixos/nijusan/configuration.nix;

          darwinConfigurations.patchbook = mkDarwinSystem "aarch64-darwin" ./darwin/patchbook.nix;

          darwinConfigurations.logamma = mkDarwinSystem "aarch64-darwin" ./darwin/logamma;

          homeConfigurations."logan@nijusan" = mkHomeConfiguration "x86_64-linux" ./home-manager/nijusan.nix;

          homeConfigurations."logan@wijusan" = mkHomeConfiguration "x86_64-linux" ./home-manager/wijusan.nix;
        };

      debug = true; # used by mkReplAttrs
    };
}
