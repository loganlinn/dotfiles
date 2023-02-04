{ self, lib, flake-parts-lib, ... }:

let

  inherit (flake-parts-lib)
    mkPerSystemOption;

  inherit (lib)
    mkOption
    mkPackageOption
    types;

in
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  options = {
    perSystem = mkPerSystemOption
      ({ config, self', inputs', pkgs, system, ... }: {

        options.modules.dev.java = {
          package = mkPackageOption pkgs "jdk" { default = [ "jdk11" ]; }; # TODO jdk19
          additionalPackages = mkOption {
            description = ''
              Java packages to install. Typical values are pkgs.jdk or pkgs.jre. Example:
              ```
                my.java.additionalPackages = {
                  inherit (pkgs) jdk11 jdk14 jdk15;
              };
              ```
              This snippet:
              1. Generates environment variables `JAVA_HOME11` and `JAVA_HOME14`
              2. Generates aliases `java11` and `java14`
            '';
            default = { };
            type = with types; attrsOf package;
          };
        };

        options.modules.dev.node = {
          package = mkPackageOption pkgs "nodejs" { };
          additionalPackages = mkOption {
            default = { };
            type = with types; attrsOf package;
          };
        };
      });
  };

  config = {
    perSystem = { config, self', inputs', pkgs, lib, ... }:
      let
        javaCfg = config.modules.dev.java;
        javaAliases = mapAttrs' (name: value: nameValuePair "java_${name}" "${value.home}/bin/java") javaPkgs;
        javaTmpfiles = mapAttrsFlatten (name: value: "L+ /nix/java${name} - - - - ${value.home}") javaPkgs;
        javaEnvVariables = mapAttrs' (name: value: nameValuePair "JAVA_HOME_${toUpper (escapeDashes name)}" "${value.home}") javaPkgs;

        nodeCfg = config.modules.dev.node;
        nodePkgs = nodeCfg.additionalPackages;
        nodeAliases = mapAttrs' (name: value: nameValuePair name "${value}/bin/node") nodePkgs;
      in
      {

        overlayAttrs = {
          inherit (config.packages) jdk;
        };

        packages.jdk = javaCfg.package;

        environment.variables = javaEnvVariables // defaultEnvVarialbes;
        environment.shellAliases = javaAliases // nodeAliases;
        systemd.tmpfiles.rules = javaTmpfiles;
      };

  };
}
