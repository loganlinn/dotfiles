{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.my.emacs;

  # External requirements for Doom modules.
  # These are derived from the "Installation" section from module READMEs.
  # See: https://github.com/doomemacs/doomemacs/tree/master/modules
  # TODO devise a way for this to be linked with init.el.
  doomModules = mkDoomModules (
    with pkgs;
    {
      ":app irc" = [ gnutls ];
      ":checkers spell +aspell" = [
        (aspellWithDicts (
          ds: with ds; [
            en
            en-computers
            en-science
          ]
        ))
      ];
      ":editor format" = [ nodePackages.prettier ];
      ":emacs dired" = [
        fd
        ffmpegthumbnailer
        gnutar
        imagemagick
        mediainfo
        poppler_utils
        unzip
      ];
      ":emacs undo" = [ zstd ];
      # ":lang clojure +lsp" = [ clojure-lsp ];
      # ":lang elixir +lsp" = [ elixir-ls ];
      # ":lang go +lsp" = [ gopls ];
      # ":lang java +lsp" = [ java-language-server ];
      ":lang latex" = [ texlive.combined.scheme-medium ];
      ":lang org +gnuplot" = [ gnuplot ];
      ":lang org +pandoc" = [ pandoc ];
      ":lang org +roam" = [ sqlite ];
      ":lang sh +lsp" = [ bash-language-server ];
      ":lang sh" = [
        shellcheck
        shfmt
      ];
      # ":lang terraform" = [ terraform ];
      # ":lang zig +lsp" = [ zls ];
      ":term vterm" = {
        programs.emacs.extraPackages = epkgs: [ epkgs.vterm ];
      };
      ":tools direnv" = [ direnv ];
      ":tools editorconfig" = [ editorconfig-core-c ];
      ":tools just" = [ just ];
      ":tools lookup" = [
        ripgrep
        sqlite
        wordnet
      ];
      ":tools magit" = {
        programs.git.enable = true;
      };
      ":tools make" = [ gnumake ];
      ":tools pass" = [
        pass
        gnupg
      ];
      # ":tools pdf" = [
      #   # for building epdfinfo (i.e. M-x pdf-tools-install)
      #   pkgconfig
      #   autoconf
      #   automake
      #   libpng
      #   zlib
      #   poppler
      #   poppler_gi
      # ];
      # ":lang hugo" = [hugo];
      # ":lang org +jupyter" = [(python3.withPackages(ps: with ps; [jupyter]))];
    }
  );

  mkDoomModules =
    modules:
    mapAttrs (
      name: value:
      if isList value then
        { home.packages = value; }
      else
        assert (isAttrs value); # function modules are not supported b/c these will be wrapped with mkIf
        value
    ) modules;

in
{
  options.my.emacs =
    let
      pathStr = with types; coercedTo path toString str;
    in
    {
      enable = mkEnableOption "Emacs" // {
        default = true;
      };

      configDir = mkOption {
        type = pathStr;
        default = "${config.xdg.configHome}/emacs";
        description = "Path to `user-emacs-directory`";
        example = literalExpression ''"''${config.home.homeDirectory}/.emacs.d"'';
      };

      doom = {
        enable = mkEnableOption "Doom Emacs configuration framework" // {
          default = true;
        };

        configDir = mkOption {
          type = pathStr;
          default = "${config.xdg.configHome}/doom";
          description = "Path to private configuration for Doom Emacs";
          example = literalExpression ''"''${config.home.homeDirectory}/.doom.d"'';
        };
      };
    };

  config = mkMerge (
    [
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
        home.packages = with pkgs; [
          binutils # for native-comp
          emacs-all-the-icons-fonts
        ];

        # doom cli
        home.sessionPath = [ "${cfg.configDir}/bin" ];

        home.sessionVariables.DOOMDIR = "${removeSuffix "/" cfg.doom.configDir}/"; # no trailing slash!

        # Automatically clone doom emacs repos
        home.activation = {
          setupDoomEmacsConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
            if ! [ -d "${cfg.configDir}" ]; then
              run ${pkgs.git}/bin/git clone $VERBOSE_ARG --depth=1 --single-branch "https://github.com/doomemacs/doomemacs.git" "${cfg.configDir}"
              run "${cfg.configDir}"/bin/doom install
            fi
          '';

          setupDoomPrivateConfig = hm.dag.entryBefore [ "setupDoomEmacsConfig" ] ''
            if ! [ -d "${cfg.doom.configDir}" ]; then
              run ${pkgs.git}/bin/git clone $VERBOSE_ARG https://github.com/loganlinn/.doom.d.git "${cfg.doom.configDir}"
            fi
          '';
        };
      })
    ]
    ++ (mapAttrsToList (name: value: mkIf (cfg.enable && cfg.doom.enable) value) doomModules)
  );
}
