{ config, lib, pkgs, ... }:

let
  inherit (lib) getExe;
  emacsRepoUrl = "https://github.com/doomemacs/doomemacs";
  doomRepoUrl = "https://github.com/loganlinn/.doom.d";
  emacsDir = "${config.xdg.configHome}/emacs";
  doomDir = "${config.xdg.configHome}/doom";
in
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-unstable.override {
      withGTK3 = true;
      withXwidgets = true;
      withSQLite3 = true;
    };
    extraPackages = epkgs: [ epkgs.vterm ];
  };

  services.emacs = {
    enable = true;
    startWithUserSession = true;
    defaultEditor = false;
  };

  home.packages = with pkgs; [
    binutils # for native-comp
    gnutls # for TLS connectivity
    git
    ripgrep
    fd # for faster projectile indexing
    imagemagick # for image-dired
    zstd # for undo-fu-session/undo-tree compression
    emacs-all-the-icons-fonts
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ])) # :checkers spell
    wordnet # English thesaurus backend (used by synosaurus.el)
    editorconfig-core-c # per-project style config
    sqlite # :tools lookup & :lang org +roam
    texlive.combined.scheme-medium # :lang latex & :lang org (latex previews)
    (writeShellScriptBin "doomer" ''doom run "$@" &'') # doom launch wrapper
    nodePackages.prettier # css, html, js, jsx
  ];


  home.sessionPath = [
    "${emacsDir}/bin" # doom CLI
  ];

  home.sessionVariables = {
    # NOTE: trailing slash is significant
    EMACSDIR = "${emacsDir}/";
    DOOMDIR = "${doomDir}/";
  };

  home.shellAliases = {
    et = "emacs -nw";
    erepl = "rlwrap doom run --repl";
  };

  # Automatically clone doom emacs repos
  home.activation =
    let
      git = "${pkgs.git}/bin/git";
    in
    {
      cloneEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ! [ -d "${emacsDir}"/.git ]; then
          $DRY_RUN_CMD ${git} clone $VERBOSE_ARG --depth=1 --single-branch "${emacsRepoUrl}" "${emacsDir}"
        fi
      '';
      cloneDoomConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ! [ -d "${doomDir}" ]; then
          $DRY_RUN_CMD ${git} clone $VERBOSE_ARG "${doomRepoUrl}" "${doomDir}"
        fi
      '';
    };
}
