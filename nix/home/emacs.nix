{ config, lib, pkgs, emacs, ... }:

let
  forgeUrl = "https://github.com";
  emacsRepoUrl = "${forgeUrl}/doomemacs/doomemacs";
  doomRepoUrl = "${forgeUrl}/loganlinn/.doom.d";
  emacsDir = "${config.home.homeDirectory}/.emacs.d";
  doomDir = "${config.home.homeDirectory}/.doom.d";
in {
  programs.emacs = {
    enable = true;
    package = pkgs.emacsNativeComp;
    extraPackages = epkgs: with epkgs; [ vterm ];
  };

  services.emacs = { enable = true; };

  home.packages = with pkgs; [
    ## Emacs itself
    binutils # native-comp needs 'as', provided by this
    # 28.2 + native-comp
    # ((emacsPackagesFor emacsNativeComp).emacsWithPackages
    #   (epkgs: [ epkgs.vterm ]))

    ## Doom dependencies
    git
    (ripgrep.override { withPCRE2 = true; })
    gnutls # for TLS connectivity

    ## Optional dependencies
    fd # faster projectile indexing
    imagemagick # for image-dired

    # in-emacs gnupg prompts
    # (lib.mkIf (programs.gnupg.agent.enable) pinentry_emacs)
    pinentry_emacs

    zstd # for undo-fu-session/undo-tree compression

    ## Module dependencies
    # :checkers spell
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    # :tools editorconfig
    editorconfig-core-c # per-project style config
    # :tools lookup & :lang org +roam
    sqlite
    # :lang latex & :lang org (latex previews)
    texlive.combined.scheme-medium

    emacs-all-the-icons-fonts
  ];

  home.sessionPath = [
    "${emacsDir}/bin"
  ];

  home.sessionVariables = {
    # NOTE: trailing slash is significant
    EMACSDIR = "${emacsDir}/";
    DOOMDIR  = "${doomDir}/";
  };

  home.shellAliases = {
    et = "${pkgs.emacs}/bin/emacs -nw";
  };

  home.activation.cloneEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! [ -d "${emacsDir}"/.git ]; then
       ${pkgs.git}/bin/git clone --depth=1 --single-branch "${emacsRepoUrl}" "${emacsDir}"
    fi
  '';

  home.activation.cloneDoomConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! [ -d "${doomDir}" ]; then
       ${pkgs.git}/bin/git clone "${doomRepoUrl}" "${doomDir}"
    fi
  '';
}
