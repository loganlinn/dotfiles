{ pkgs, ... }:
let jdk11 = pkgs.jdk11;
in {

  programs.java = {
    enable = true;
    package = jdk11;
  };

  home.packages = with pkgs; [
    (clojure.override { jdk = jdk11; })
    clojure-lsp
    (leiningen.override { jdk = jdk11; })
    clj-kondo
    babashka
    jet
    neil
    zprint
    (polylith.override { jdk = jdk11; })
  ];
}
