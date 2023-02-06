{
  description = "loganlinn's (highly indecisive) flake";

  inputs = {
    # package repos
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    # system mangement
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # overlays
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    # eww.url = "github:elkowar/eww";
    # eww.inputs.nixpkgs.follows = "nixpkgs";

    # utils
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
      { inherit inputs; }
      {
        imports = [ ./flake-modules ];
        systems = [ "x86_64-linux" "aarch64-darwin" ];
        debug = true;
      };
}
