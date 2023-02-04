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
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ ./flake-parts ];

    systems = [
      "x86_64-linux"
      "aarch64-darwin"
      # "x86_64-darwin"
      # "aarch64-linux"
    ];

    # flake = {
    # options.mySystem = lib.mkOption { default = config.allSystems.${builtins.currentSystem}; };



    # darwinConfigurations."logan@patchbook" = darwin.lib.darwinSystem {
    #   inherit inputs;
    #   system = "aarch64-darwin";
    #   pkgs = pkgs."aarch64-darwin";
    #   modules = [ ./nix/hosts/patchbook/darwin.nix ];
    # };
    # };
  };
}
