{ pkgs
, ...
}:

let
  jdk = pkgs.jdk11;
in
{

  home.sessionVariables = {
    JAVA_11_HOME = "${pkgs.jdk11}";
    JAVA_17_HOME = "${pkgs.jdk17}";
    JAVA_19_HOME = "${pkgs.jdk19}";
  };

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
