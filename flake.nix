{
  description = "loganlinn's (highly indecisive) flake";

  inputs = {
    # packages
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # builders
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:vaxerski/Hyprland/v0.21.0beta";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    # overlays
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    # eww.url = "github:elkowar/eww";
    # eww.inputs.nixpkgs.follows = "nixpkgs";
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    # libs + data
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    grub2-themes.inputs.nixpkgs.follows = "nixpkgs";
    grub2-themes.url = "github:AnotherGroupChat/grub2-themes-png";
    mission-control.url = "github:Platonic-Systems/mission-control";
    nix-colors.url = "github:misterio77/nix-colors";
    sops-nix.url = "github:Mic92/sops-nix";
    # process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";

    # shells
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    # devshellurl = "github:numtide/devshell";
    # devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
      { inherit inputs; }
      {
        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.flake-root.flakeModule
          inputs.mission-control.flakeModule
          ./flake-modules
          ./home-manager/flake-module.nix
          ./nixos/flake-module.nix
        ];
        systems = [ "x86_64-linux" "aarch64-darwin" ];
        debug = true;
      };
}
