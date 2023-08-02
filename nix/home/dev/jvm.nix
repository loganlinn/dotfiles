{ pkgs, ... }:

let
  jdk = pkgs.jdk17;
in
{

  home.sessionVariables = {
    # JAVA_11_HOME = "${pkgs.jdk11}";
    # JAVA_17_HOME = "${pkgs.jdk17}";
    # JAVA_19_HOME = "${pkgs.jdk19}";
    # GRAALVM_HOME = with pkgs; (graalvm17-ce.override {
    #   products = with graalvmCEPackages; [
    #     # js-installable-svm-java17
    #     # llvm-installable-svm-java17
    #     native-image-installable-svm-java17
    #     # python-installable-svm-java17
    #     # ruby-installable-svm-java17
    #     # wasm-installable-svm-java17
    #   ];
    # });
  };

  programs.java = {
    enable = true;
    package = jdk;
  };

  home.packages = with pkgs; [
    # (kotlin.override { jre = jdk; })
    (clojure.override { inherit jdk; })
    (maven.override { inherit jdk; })
    (leiningen.override { inherit jdk; })
    (polylith.override { inherit jdk; })
    babashka
    bbin
    clj-kondo
    clojure-lsp
    jet
    neil
    zprint
    rep
  ];
}
