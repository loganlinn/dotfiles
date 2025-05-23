{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.dev;

  submodules = [
    "clojure"
    "crystal"
    "elm"
    "golang"
    "java"
    "lua"
    "markdown"
    "node"
    "nodejs"
    "proto"
    "python"
    "ruby"
    "rust"
    "shell"
    "web"
  ];

  submoduleOptions =
    genAttrs submodules
    (name:
      mkOption {
        type = types.submoduleWith {
          enable = mkEnableOption name;
          packages = mkOption {
            default = [];
            type = with types; listOf package;
          };
        };
      });
in {
  options.modules.dev = {
    enable = mkEnableOption "dev";
  };

  config = mkIf cfg.enable {
    # TODO cfg.${submodule}

    programs.java = {
      enable = true;
      package = cfg;
    };

    home.packages = with pkgs; [
      (clojure.override {inherit jdk;})
      (maven.override {inherit jdk;})
      (leiningen.override {inherit jdk;})
      babashka
      clj-kondo
      clojure-lsp
      jet
      neil
      zprint
    ];
  };
}
