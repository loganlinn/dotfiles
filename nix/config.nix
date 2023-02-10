{ pkgs, ... }:
{

  nix = {
    enable = true;
    package = pkgs.nixUnstable;
    # settings.substiters = [
    #   "https://cache.nixos.org"
    # ];
    extraOptions = "experimental-features = nix-command flakes";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      # https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _pkg: true;
    };
  };
}
