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

    # overlays
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    # eww.url = "github:elkowar/eww";
    # eww.inputs.nixpkgs.follows = "nixpkgs";
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    # libs
    nixlib.url = "github:nix-community/nixpkgs.lib";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nix-colors.url = "github:misterio77/nix-colors";

    # shells
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    # devshellurl = "github:numtide/devshell";
    # devshell.inputs.nixpkgs.follows = "nixpkgs";

    # data
    fzf-git.url = "github:junegunn/fzf-git.sh";
    fzf-git.flake = false;
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
