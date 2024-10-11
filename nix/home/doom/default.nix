{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  emacsdir = "${config.xdg.configHome}/emacs"; # i.e. doom framework
  doomdir = "${config.xdg.configHome}/doom"; # i.e. doom private config
in
{
  home.packages = concatLists (attrValues (import ./packages.nix pkgs));
  home.sessionPath = [ "${emacsdir}/bin" ]; # doom cli
  home.sessionVariables.EMACSDIR = "${removeSuffix "/" emacsdir}/"; # trailing sep expected
  home.sessionVariables.DOOMDIR = "${removeSuffix "/" doomdir}/"; # trailing sep expected
  home.activation = {
    doomEmacs = hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! [ -d "${emacsdir}" ]; then
        run ${pkgs.git}/bin/git clone $VERBOSE_ARG --depth=1 --single-branch "https://github.com/doomemacs/doomemacs.git" "${emacsdir}"
        run "${emacsdir}"/bin/doom install
      fi
    '';
    doomConfig = hm.dag.entryBefore [ "doomEmacs" ] ''
      if ! [ -d "${doomdir}" ]; then
        run ${pkgs.git}/bin/git clone $VERBOSE_ARG https://github.com/loganlinn/.doom.d.git "${doomdir}"
      fi
    '';
  };
}
