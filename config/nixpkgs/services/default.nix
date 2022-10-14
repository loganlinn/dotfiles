{ config
, pkgs
, self
, ...
}:

{
  imports = [
    ./common.nix
    ./emacs.nix
  ];
}

