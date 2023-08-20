{ config, lib, pkgs, ... }:

with lib;

let
  aspell = pkgs.aspellWithDicts (ds: with ds; [ en en-computers en-science ]);

  doomer = pkgs.writeShellScriptBin "doomer" ''
    ${pkgs.coreutils}/bin/nohup doom run "$@" >/dev/null 2>&1&
  '';

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

    programs.git.enable = true;
    programs.ripgrep.enable = true;
    programs.pandoc.enable = true; # :lang (org +pandoc)

    home.packages = with pkgs; [
      aspell
      binutils # for native-comp
      doomer
      editorconfig-core-c # per-project style config
      emacs-all-the-icons-fonts
      fd # for faster projectile indexing
      gnuplot # :lang (org +gnuplot)
      gnutls # for TLS connectivity
      hugo # :lang (org +hugo)
      imagemagick # for image-dired
      nodePackages.prettier # css, html, js, jsx
      sqlite # :tools lookup & :lang org +roam
      texlive.combined.scheme-medium # :lang latex & :lang org (latex previews)
      wordnet # English thesaurus backend (used by synosaurus.el)
      zstd # for undo-fu-session/undo-tree compression
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
