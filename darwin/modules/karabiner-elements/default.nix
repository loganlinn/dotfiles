{ config, lib, pkgs, ... }:

{
  config = {
    # https://github.com/LnL7/nix-darwin/issues/1041
    services.karabiner-elements.enable = false;
    # since nix-darwin's module is broken, we use brew.
    homebrew.casks = [ "karabiner-elements" ];
    # TODO config file
  };
}
