{
  allowUnfree = true;
  # https://github.com/nix-community/home-manager/issues/2942
  allowUnfreePredicate = _pkg: true;

  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
