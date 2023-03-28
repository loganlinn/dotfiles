{ config, lib, pkgs, ... }:

let
  inherit (lib) getExe;
  emacsRepoUrl = "https://github.com/doomemacs/doomemacs";
  doomRepoUrl = "https://github.com/loganlinn/.doom.d";
  emacsDir = "${config.xdg.configHome}/emacs";
  doomDir = "${config.xdg.configHome}/doom";
in
{

  imports = [

  ];

  programs.emacs = {
    enable = true;
    # package = pkgs.emacsNativeComp;
    package = pkgs.emacsUnstable;
    extraPackages = epkgs: [ epkgs.vterm ];
  };

  services.emacs.enable = true;

  home.packages = with pkgs; [
    binutils # for native-comp
    gnutls # for TLS connectivity
    git
    ripgrep
    fd # for faster projectile indexing
    imagemagick # for image-dired
    zstd # for undo-fu-session/undo-tree compression
    emacs-all-the-icons-fonts
    ## Module dependencies
    # :checkers spell
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    # :tools editorconfig
    editorconfig-core-c # per-project style config
    # :tools lookup & :lang org +roam
    sqlite
    # :lang latex & :lang org (latex previews)
    texlive.combined.scheme-medium
  ];


  home.sessionPath = [
    "${emacsDir}/bin" # doom CLI
  ];

  home.sessionVariables = {
    # NOTE: trailing slash is significant
    EMACSDIR = "${emacsDir}/";
    DOOMDIR = "${doomDir}/";
  };

  home.shellAliases = { et = "${pkgs.emacs}/bin/emacs -nw"; };

  # Automatically clone doom emacs repos
  home.activation = {
    cloneEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! [ -d "${emacsDir}"/.git ]; then
        ${
          getExe pkgs.git
        }/bin/git clone --depth=1 --single-branch "${emacsRepoUrl}" "${emacsDir}"
      fi
    '';
    cloneDoomConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! [ -d "${doomDir}" ]; then
        ${getExe pkgs.git} clone "${doomRepoUrl}" "${doomDir}"
      fi
    '';
  };
}
