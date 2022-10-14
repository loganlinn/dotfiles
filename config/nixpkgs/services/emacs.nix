{ config
, pkgs
, self
, lib
, ...
}:

{

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  # TODO Look into https://github.com/vlaci/nix-doom-emacs

  # home.file = {
  #   ".emacs.d" = {
  #     source = ...
  #     recursive = true;
  #   };
  # };

  services.emacs = with pkgs; {
    enable = true;
    package = emacsUnstable;
    client = {
      enable = true;
    };
    startWithUserSession = true;
    defaultEditor = true;
  };

}
