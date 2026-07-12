{
  config,
  lib,
  pkgs,
  osConfig ? {},
  ...
}:
with lib; let
  emacsdir = "${config.xdg.configHome}/emacs"; # i.e. github.com/doomemacs/doomemacs
  doomdir = "${config.xdg.configHome}/doom"; # i.e. github.com/loganlinn/.doom.d
  # doom's CLI shells out to `emacs`, which on darwin is provided by homebrew
  # (emacs-plus) and isn't on the restricted PATH used during HM activation.
  # osConfig.homebrew.prefix (nix-darwin) resolves per-arch, matching `brew --prefix`.
  emacsPath = optionalString pkgs.stdenv.hostPlatform.isDarwin "${osConfig.homebrew.prefix or "/opt/homebrew"}/bin:";
in {
  home.packages = concatLists (attrValues (import ./packages.nix pkgs));
  home.sessionPath = ["${emacsdir}/bin"]; # doom cli
  home.sessionVariables.EMACSDIR = "${removeSuffix "/" emacsdir}/"; # trailing sep expected
  home.sessionVariables.DOOMDIR = "${removeSuffix "/" doomdir}/"; # trailing sep expected
  # TODO: migrate to my.src-get.repos with links
  home.activation = {
    doomConfig = hm.dag.entryBefore ["doomEmacs"] ''
      if ! [ -d "${doomdir}" ]; then
        run ${pkgs.git}/bin/git clone $VERBOSE_ARG https://github.com/loganlinn/.doom.d.git "${doomdir}"
      fi
    '';
    doomEmacs = hm.dag.entryAfter ["writeBoundary"] ''
      if ! [ -d "${emacsdir}" ]; then
        run ${pkgs.git}/bin/git clone $VERBOSE_ARG --depth=1 --single-branch "https://github.com/doomemacs/doomemacs.git" "${emacsdir}"
      fi
      # Install doom whenever it isn't fully installed (no .local/). Keying this
      # on the clone alone left a half-installed state that never self-healed if
      # `doom install` failed (e.g. emacs missing from PATH). `--force` suppresses
      # prompts since activation has no TTY.
      if [ -x "${emacsdir}/bin/doom" ] && ! [ -d "${emacsdir}/.local" ]; then
        PATH="${emacsPath}$PATH" run "${emacsdir}/bin/doom" install --force
      fi
    '';
  };
}
