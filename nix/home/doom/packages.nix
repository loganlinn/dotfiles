# External requirements for Doom modules.
# These are derived from the "Installation" section from module READMEs.
# See: https://github.com/doomemacs/doomemacs/tree/master/modules
# TODO devise a way for this to be linked with init.el.
pkgs:
with pkgs; {
  default = [
    binutils # for native-comp
    emacs-all-the-icons-fonts
    fd
    ripgrep
  ];

  ":app irc" = [gnutls];

  # ":checkers spell +aspell" = [
  #   (aspellWithDicts (
  #     ds: with ds; [
  #       en
  #       en-computers
  #       en-science
  #     ]
  #   ))
  # ];

  ":checkers spell +hunspell" = [hunspell];

  ":editor format" = [nodePackages.prettier];

  ":emacs dired" = [
    fd
    ffmpegthumbnailer
    gnutar
    imagemagick
    mediainfo
    poppler_utils
    unzip
  ];

  ":emacs undo" = [zstd];

  # ":lang cc" = [ glslang ];

  # ":lang clojure" = [ cljfmt clojure-lsp ];

  ":lang docker" = [dockfmt];

  # ":lang elixir +lsp" = [ elixir-ls ];

  ":lang go" = [
    gomodifytags
    gopls
    gore
    gotests
  ];

  # ":lang java +lsp" = [ java-language-server ];

  ":lang javascript" = [nodePackages.prettier];

  ":lang latex" = [texlive.combined.scheme-medium];

  ":lang markdown" = [python3Packages.grip];

  ":lang org +gnuplot" = [gnuplot];

  ":lang org +pandoc" = [pandoc];

  ":lang org +roam" = [sqlite];

  ":lang sh +lsp" = [bash-language-server];

  ":lang sh" = [
    shellcheck
    shfmt
  ];

  # ":lang terraform" = [ terraform ];

  # ":lang zig +lsp" = [ zls ];

  # ":term vterm" = {
  #   programs.emacs.extraPackages = epkgs: [ epkgs.vterm ];
  # };

  ":tools direnv" = [direnv];

  ":tools editorconfig" = [editorconfig-core-c];

  ":tools just" = [just];

  ":tools lookup" = [
    ripgrep
    sqlite
    wordnet
  ];

  ":tools make" = [gnumake];

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
