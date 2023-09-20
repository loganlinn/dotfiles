{ config, pkgs, lib, ... }:

with lib;

let
  inherit (config.lib.file) mkOutOfStoreSymlink;

  cfg = config.my.java;

in {
  options.my.java = {
    enable = mkEnableOption "java" // { default = true; };

    package = mkPackageOption pkgs "jdk" { };

    extraJvms = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };

    finalJvms = mkOption {
      type = types.listOf types.package;
      readOnly = true;
      default = [ cfg.package ] ++ cfg.extraJvms
        ++ (optional cfg.graalvm.enable cfg.graalvm.package);
    };

    toolOptions = mkOption {
      type = types.listOf types.str;
      description = ''
        Initial options supply to all VMs in user environment.
        See: https://docs.oracle.com/javase/8/docs/platform/jvmti/jvmti.html#tooloptions
      '';
      default = with cfg;
        (optional enableCommercialFeatures "-XX:+UnlockCommercialFeatures")
        ++ (optional enableFlightRecorder "-XX:+FlightRecorder")
        ++ (optional (illegalAccess != null)
          "--illegal-access=${illegalAccess}")
        ++ (forEach exports (v: "--add-export=${v}"))
        ++ (forEach opens (v: "--add-opens=${v}"));
    };

    graalvm = {
      enable = mkEnableOption "graalvm";
      package = mkPackageOption pkgs "graalvm-ce" { };
    };

    illegalAccess = mkOption {
      type = types.nullOr (types.oneOf [ "permit" "warn" "debug" "deny" ]);
      default = null;
    };

    exports = mkOption {
      type = types.listOf types.str;
      description = ''
        https://docs.oracle.com/en/java/javase/17/migrate/migrating-jdk-8-later-jdk-releases.html#GUID-2F61F3A9-0979-46A4-8B49-325BA0EE8B66
      '';
      default = [ ];
    };

    opens = mkOption {
      type = types.listOf types.str;
      description = ''
        https://docs.oracle.com/en/java/javase/17/migrate/migrating-jdk-8-later-jdk-releases.html#GUID-2F61F3A9-0979-46A4-8B49-325BA0EE8B66
      '';
      default = [ ];
    };

    enableCommercialFeatures = mkOption {
      type = types.bool;
      default = false;
    };

    enableFlightRecorder = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = cfg.enableFlightRecorder -> cfg.enableCommercialFeatures;
      message =
        "Java Flight Recorder requires a commercial license for use in production.";
    }];

    programs.java.enable = true;
    programs.java.package = cfg.package;

    home.sessionVariables.JAVA_TOOL_OPTIONS = escapeShellArgs cfg.toolOptions;

    home.packages = with pkgs; [
      # packages which depend on
      (clojure.override { jdk = cfg.package; })
      (maven.override { jdk = cfg.package; })
      (leiningen.override { jdk = cfg.package; })
      babashka
      bbin
      clj-kondo
      clojure-lsp
      jet
      neil
      zprint
      rep
    ];

    # Create a symlink that applications can depend on rather than nix-store
    xdg.dataFile = foldl' mergeAttrs { }
      (forEach cfg.finalJvms (p: { "jvms/${p.meta.name}".source = p; }));
  };
}
