{
  config,
  lib,
  pkgs,
  ...
}: {
  home.sessionVariables = {
    NNN_OPTS = lib.concatStringsSep "" [
      "H" # show hidden files
      "d" # detail mode
      "e" # text in $VISUAL/$EDITOR/vi
      "o" # open files only on Enter
    ];
  };

  programs.nnn = {
    enable = true;

    package = pkgs.nnn.override {withNerdIcons = true;};

    bookmarks = {
      d = "~/Downloads";
      D = "~/Documents";
      p = "~/Pictures";
      v = "~/Videos";
      "." = "~/.dotfiles";
    };

    plugins = {
      src =
        (pkgs.fetchFromGitHub {
          owner = "jarun";
          repo = "nnn";
          rev = "v4.0";
          sha256 = "sha256-Hpc8YaJeAzJoEi7aJ6DntH2VLkoR6ToP6tPYn3llR7k=";
        })
        + "/plugins";
      mappings = {
        c = "fzcd";
        f = "finder";
        v = "imgview";
      };
    };
  };
}
