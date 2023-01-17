{ config, lib, pkgs, ... }:

with lib;
with lib.my;

let cfg = config.modules.editors.emacs;
in {

  options.modules.editors.emacs = {
    enable = mkEnableOption "emacs editor";
    doom = rec {
      enable = mkEnableOption "doom emacs config";
      repoUrl = mkOption {
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    programs.emacs = {
      enable = mkDefault true;
      package = mkDefault pkgs.emacsNativeComp;
      extraPackages = epkgs: [ epkgs.vterm ];
    };

    services.emacs.enable = mkDefault true;

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

  };
}
