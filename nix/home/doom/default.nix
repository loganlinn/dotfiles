{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  emacsdir = "${config.xdg.configHome}/emacs";
  doomdir = "${config.xdg.configHome}/doom";
in
{
  home.packages =
    (with pkgs; [
      binutils # for native-comp
      emacs-all-the-icons-fonts
    ])
    ++ (concatLists (attrValues (import ./packages.nix pkgs)));

  home.sessionPath = [ "${emacsdir}/bin" ];

  home.sessionVariables.EMACSDIR = "${removeSuffix "/" emacsdir}/"; # trailing sep expected
  home.sessionVariables.DOOMDIR = "${removeSuffix "/" doomdir}/"; # trailing sep expected

  home.activation = {
    setupDoomEmacsConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! [ -d "${emacsdir}" ]; then
        run ${pkgs.git}/bin/git clone $VERBOSE_ARG --depth=1 --single-branch "https://github.com/doomemacs/doomemacs.git" "${emacsdir}"
        run "${emacsdir}"/bin/doom install
      fi
    '';

    setupDoomPrivateConfig = hm.dag.entryBefore [ "setupDoomEmacsConfig" ] ''
      if ! [ -d "${doomdir}" ]; then
        run ${pkgs.git}/bin/git clone $VERBOSE_ARG https://github.com/loganlinn/.doom.d.git "${doomdir}"
      fi
    '';
  };
}
