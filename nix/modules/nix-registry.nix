{ nixpkgs, home-manager, ... }: {
  nix.registry = {
    nixpkgs.to = {
      type = "path";
      path = nixpkgs;
    };
    home-manager.to = {
      type = "path";
      path = home-manager;
    };
  };
}
