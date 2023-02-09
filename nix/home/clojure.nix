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

  home.sessionPath = [
    "$HOME/.jenv/bin"
  ];

  home.file.".jenv".source = fetchFromGitHub {
    owner = "jenv";
    repo = "jenv";
    rev = "0.5.5";
    hash = "sha256-0JDeR2sywA74eTHyXadS8A9Ggt682ZGBNE2gK/wJOhA=";
  };

  programs.zsh.initExtra = ''eval "$(jenv init -)"'';

  programs.bash.initExtra = ''eval "$(jenv init -)"'';

  # TODO setup jenv file

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
