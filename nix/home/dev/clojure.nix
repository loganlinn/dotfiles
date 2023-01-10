{
  pkgs,
  ...
}: let
  jdk = pkgs.jdk11;
in {

  programs.java = {
    enable = true;
    package = jdk;
  };

  home.packages = with pkgs; [
    (clojure.override { inherit jdk; })
    (maven.override { inherit jdk; })
    (leiningen.override { inherit jdk; })
    (polylith.override { inherit jdk; })
    babashka
    clj-kondo
    clojure-lsp
    jet
    neil
    zprint
  ];
}
