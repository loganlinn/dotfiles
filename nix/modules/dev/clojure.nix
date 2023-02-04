{ config, options, lib, pkgs, ... }:

with lib;

let

  cfg' = config.modules.dev;
  cfg = cfg'.clojure;

in
{
  options.modules.dev.clojure = {
    enable = mkEnableOption "Clojure";
    java.package = mkPackageOption pkgs "jdk" {
      default = [ "jdk11" ]; # TODO jdk19
    };
  };

  config = mkIf cfg.enable {

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
  };
}
