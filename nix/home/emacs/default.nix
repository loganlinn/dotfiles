{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.my.emacs;
in
{
  options.my.emacs =
    let
      pathStr = with types; coercedTo path toString str;
    in
    {
      enable = mkEnableOption "Emacs" // { default = true; };

      configDir = mkOption {
        type = pathStr;
        default = "${config.xdg.configHome}/emacs";
        description = "Path to `user-emacs-directory`";
        example = literalExpression ''"''${config.home.homeDirectory}/.emacs.d"'';
      };

      doom = {
        enable = mkEnableOption "Doom Emacs configuration framework" // { default = true; };

        configDir = mkOption {
          type = pathStr;
          default = "${config.xdg.configHome}/doom";
          description = "Path to private configuration for Doom Emacs";
          example = literalExpression ''"''${config.home.homeDirectory}/.doom.d"'';
        };
      };
    };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.emacs = {
        enable = true;
        package = lib.mkDefault pkgs.emacs-unstable; # most recent git tag
        extraPackages = epkgs: [ epkgs.vterm ];
      };

      services.emacs = {
        package = lib.mkDefault config.programs.emacs.package;
        client = lib.mkDefault {
          enable = true;
          arguments = [ "-c" ];
        };
      };

      programs.zsh.initExtra = ''
        function e() {
            hash emacs || return 1
            command emacs "$@" &
            disown %+;
        }

        function ec() {
            hash emacsclient || return 1
            command emacsclient --alternate-editor="" --create-frame "$@" &
            disown %+;
        }

        function et() {
          emacs -nw "$@"
        }
      '';

      home.sessionVariables.EMACSDIR = "${removeSuffix "/" cfg.configDir}/"; # no trailing slash!
    })
    (mkIf (cfg.enable && cfg.doom.enable) {
      programs.emacs.enable = true;

      programs.git.enable = true;

      programs.ripgrep.enable = true;

      programs.pandoc.enable = true; # :lang (org +pandoc)

      home.packages = with pkgs; [
        (aspellWithDicts (
          ds: with ds; [
            en
            en-computers
            en-science
          ]
        ))
        binutils # for native-comp
        editorconfig-core-c # per-project style config
        emacs-all-the-icons-fonts
        fd # for faster projectile indexing
        gnuplot # :lang (org +gnuplot)
        gnutls # for TLS connectivity
        # hugo # :lang (org +hugo)
        just
        imagemagick # for image-dired
        nodePackages.prettier # css, html, js, jsx
        sqlite # :tools lookup & :lang org +roam
        texlive.combined.scheme-medium # :lang latex & :lang org (latex previews)
        wordnet # English thesaurus backend (used by synosaurus.el)
        zstd # for undo-fu-session/undo-tree compression
      ];

      # doom cli
      home.sessionPath = [ "${cfg.configDir}/bin" ];

      home.sessionVariables.DOOMDIR = "${removeSuffix "/" cfg.doom.configDir}/"; # no trailing slash!

      # Automatically clone doom emacs repos
      home.activation = {
        setupDoomEmacsConfig =
        hm.dag.entryAfter [ "writeBoundary" ] ''
          if ! [ -d "${cfg.configDir}" ]; then
            run ${pkgs.git}/bin/git clone $VERBOSE_ARG --depth=1 --single-branch "https://github.com/doomemacs/doomemacs.git" "${cfg.configDir}"
            run "${cfg.configDir}"/bin/doom install
          fi
        '';

        setupDoomPrivateConfig =
        hm.dag.entryBefore [ "setupDoomEmacsConfig" ] ''
          if ! [ -d "${cfg.doom.configDir}" ]; then
            run ${pkgs.git}/bin/git clone $VERBOSE_ARG https://github.com/loganlinn/.doom.d.git "${cfg.doom.configDir}"
          fi
        '';
      };
    })
  ];
}
