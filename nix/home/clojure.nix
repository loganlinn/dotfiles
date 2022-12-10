{pkgs, ...}: {
  home.packages = with pkgs; [
    clojure
    clojure-lsp
    leiningen
    clj-kondo
    babashka
    jet
    neil
    zprint
    polylith
  ];
}
