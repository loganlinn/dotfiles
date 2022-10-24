{ config
, pkgs
, self
, ...
}:

{
  imports = [
    ./common.nix
    ./neovim.nix
  ];
}
