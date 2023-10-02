{ config, pkgs, lib, ... }:

with lib;

let
  inherit (config.lib.file) mkOutOfStoreSymlink;

  cfg = config.my.java;

in {
  options.my.java = {
    enable = mkEnableOption "java" // { default = true; };

    package = mkPackageOption pkgs "jdk" { };

    toolchains = mkOption {
      description = "Additional JDK/JREs to be registered as toolchains.";
      type = types.listOf types.package;
      default = [ ];

      example = literalExpression ''
        [
          pkgs.oraclejdk
        ]
      '';
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
    }] ++ (forEach cfg.toolchains (p: {
      assertion = p.meta.mainProgram == "java";
      message =
        "Invalid Java toolchain package: ${p}: mainProgram expected to be `java`";
    }));

    programs.java.enable = true;
    programs.java.package = cfg.package;

    # this works, but is there a better way? (makeWrapper?)
    home.sessionVariables = optionalAttrs (cfg.toolOptions != [ ]) {
      JAVA_TOOL_OPTIONS = escapeShellArgs cfg.toolOptions;
    };

    home.packages = (attrValues rec {
      jdk = cfg.package;
      maven = pkgs.maven.override { inherit jdk; };
      gradle = pkgs.gradle.override {
        java = jdk;
        javaToolchains =
          remove (p: p.meta.name == jdk.meta.name) cfg.toolchains;
      };
      clojure = pkgs.clojure.override { inherit jdk; };
      clojure-lsp = pkgs.clojure-lsp.override { inherit clojure; };
      leiningen = pkgs.leiningen.override { inherit jdk; };
      inherit (pkgs)
        babashka bbin clj-kondo jet neil zprint rep gradle-completion;
    }) ++ (optional cfg.graalvm.enable cfg.graalvm.package);

    # Create a symlink that applications can depend on rather than nix-store
    xdg.dataFile = pipe cfg.toolchains [
      (map (p: {
        name = "jvms/${p.pname}";
        value = { source = p; };
      }))
      (xs:
        xs ++ [{
          name = "jvms/default";
          value = { source = cfg.package; };
        }])
      listToAttrs
    ];
  };
}
