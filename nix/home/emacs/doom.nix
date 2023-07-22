{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.my.emacs.doom;

in
{
  options.my.emacs.doom = {
    enable = mkEnableOption "doomemacs";

    emacsDir = mkOption {
      type = with types; coercedTo path toString str;
      default = "${config.xdg.configHome}/emacs";
    };

    doomDir = mkOption {
      type = with types; coercedTo path toString str;
      default = "${config.xdg.configHome}/doom";
    };

    doomRepo.url = mkOption {
      type = types.str;
      default = "https://github.com/doomemacs/doomemacs";
    };

    userRepo.url = mkOption {
      type = types.str;
      default = "https://github.com/${config.my.github.user}/.doom.d";
    };
  };

  config = mkIf cfg.enable {
    programs.emacs.enable = true;

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
      (writeShellScriptBin "doomer" ''${pkgs.coreutils}/bin/nohup doom run "$@" >/dev/null 2>&1&'') # doom run detached
      nodePackages.prettier # css, html, js, jsx
    ];

    home.sessionPath = [
      "${cfg.emacsDir}/bin" # doom CLI
    ];

    home.sessionVariables = {
      # NOTE: trailing slash is significant
      EMACSDIR = "${removeSuffix "/" cfg.emacsDir}/";
      DOOMDIR = "${removeSuffix "/" cfg.doomDir}/";
    };

    # Automatically clone doom emacs repos
    home.activation = {
      doomEmacsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ! [ -d "${cfg.emacsDir}" ]; then
          $DRY_RUN_CMD ${pkgs.git}/bin/git clone $VERBOSE_ARG --depth=1 --single-branch "${cfg.doomRepo.url}" "${cfg.emacsDir}"
          "${cfg.emacsDir}"/bin/doom install
        fi
      '';
      doomUserDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if ! [ -d "${cfg.doomDir}" ]; then
          $DRY_RUN_CMD ${pkgs.git}/bin/git clone $VERBOSE_ARG "${cfg.userRepo.url}" "${cfg.doomDir}"
        fi
      '';
    };
  };
}
