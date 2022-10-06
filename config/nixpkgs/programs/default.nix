{ config
, pkgs
, self
, ...
}:

{

  imports = [
    ./common.nix
  ];

  programs = {
    gpg.enable = true;
  };
}
