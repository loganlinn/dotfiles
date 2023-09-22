{ options, config, lib, pkgs, ... }:

with lib;

let
  yamlFormat = pkgs.formats.yaml { };

  clusterType = types.submodule ({ config, ... }: {
    options = {
      featureGates = mkOption {
        type = types.attrsOf types.bool;
        default = { };
      };
      skin = mkOption {
        type = skinType;
        default = { };
      };
    };
    freeFormType = yamlFormat.type;
  });

  stylesType = with types; attrsOf (types.attrsOf types.str);

  skinType = types.submodule ({name, config, ...}: {
    options = {
      styles = mkOption { type = types.nullOr stylesType; defualt = null; };
      source = mkOption {type = types.path;};
    };
    config = {
      source = mkIf (config.styles != {}) (
          mkDefault (pkgs.writeTextFile {
            name = "${if config.name != null then "${name}_" else ""}skin.yml";
            text = TODODODODO
          })
        );
    };
  });


  cfg = config.my.k9s;

  desktopEntryEnable = cfg.desktopEntryEnable
    && (warnIfNot isLinux "desktopEntry is only available to Linux system"
      isLinux);

  inherit (pkgs.stdenv) isLinux;
in {
  options.my.k9s = {
    enable =
      mkEnableOption "k9s - Kubernetes CLI To Manage Your Clusters In Style";

    package = mkPackageOption pkgs "k9s" { };

    clusters = mkOption {
      type = types.attrsOf clusterType;
      default = { };
      example = literalExpression ''
        {
          cluster1 = {
            featureGates = {nodeShell = false;};
            namespace = {
              active = "coolio";
              favorites = ["cassandra" "default"];
            };
            portForwardAddress = "1.2.3.4";
            shellPod = {
              image = "killerAdmin";
              limits = {
                cpu = "100m";
                memory = "100Mi";
              };
              namespace = "fred";
            };
            view = {active = "po";};
          };
        };
      '';
    };

    extraConfig = mkOption {
      type = yamlFormat.type;
      default = { };
      description = ''
        Configuration written to
        <filename>$XDG_CONFIG_HOME/k9s/config.yml</filename>. See
        <link xlink:href="https://k9scli.io/topics/config/"/>
        for supported values.
      '';
      example = literalExpression ''
        {
          clusters = {
            cluster1 = {
              featureGates = {nodeShell = false;};
              namespace = {
                active = "coolio";
                favorites = ["cassandra" "default"];
              };
              portForwardAddress = "1.2.3.4";
              shellPod = {
                image = "killerAdmin";
                limits = {
                  cpu = "100m";
                  memory = "100Mi";
                };
                namespace = "fred";
              };
              view = {active = "po";};
            };
            cluster2 = {
              namespace = {
                active = "all";
                favorites = ["all" "kube-system" "default"];
              };
              view = {active = "dp";};
            };
          };
          crumbsless = false;
          currentCluster = "minikube";
          currentContext = "minikube";
          enableMouse = true;
          headless = false;
          logger = {
            buffer = 500;
            fullScreenLogs = false;
            showTime = false;
            sinceSeconds = 300;
            tail = 200;
            textWrap = false;
          };
          maxConnRetry = 5;
          noIcons = false;
          readOnly = false;
          refreshRate = 2;
        };
      '';
    };

    skin = mkOption {
      type = yamlFormat.type;
      default = { };
      description = ''
        Skin written to
        <filename>$XDG_CONFIG_HOME/k9s/skin.yml</filename>. See
        <link xlink:href="https://k9scli.io/topics/skins/"/>
        for supported values.
      '';
      example = literalExpression ''
        body = {
          fgColor = "dodgerblue";
        };
      '';
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = ''
        Aliases written to
        <filename>$XDG_CONFIG_HOME/k9s/alias.yml</filename>. See
        <link xlink:href="https://k9scli.io/topics/aliases/"/>
        for supported values.
      '';
      example = literalExpression ''
        {
          cr = "rbac.authorization.k8s.io/v1/clusterroles";
          crb = "rbac.authorization.k8s.io/v1/clusterrolebindings";
          dep = "apps/v1/deployments";
          fred = "acme.io/v1alpha1/fredericks";
          pp = "v1/pods";
        }
      '';
    };

    plugins = mkOption {
      type = yamlFormat.type;
      default = { };
      description = ''
        Configuration written to
        <filename>$XDG_CONFIG_HOME/k9s/plugin.yml</filename>. See
        <link xlink:href="https://k9scli.io/topics/plugin/"/>
        for supported values.
      '';
      example = literalExpression ''
        fred = {
          shortCut = "Ctrl+L";
          description = "Pod logs";
          scopes = [ "po" ];
          command = lib.getExe pkgs.kubectl;
          args = ["logs" "-f" "$NAME" "-n" "$NAMESPACE" "--context" "$CONTEXT"];
        };
      '';
    };

    hotKeys = mkOption {
      type = yamlFormat.type;
      default = { };
      description = ''
        Configuration written to
        <filename>$XDG_CONFIG_HOME/k9s/hotkey.yml</filename>. See
        <link xlink:href="https://k9scli.io/topics/hotkeys/"/>
        for supported values.
      '';
    };

    views = mkOption {
      type = types.submodule {
        options = {
          columns = mkOption { type = types.listOf types.str; default = []; };
          sortColumn = mkOption { type = types.nullOr types.str; default = null; };
        };
        freeFormType = yamlFormat.type;
      };
      default = { };
      example = ''
        {
          "v1/pods" = {columns = ["AGE" "NAMESPACE" "NAME" "IP" "NODE" "STATUS" "READY"];};
          "v1/services" = {columns = ["AGE" "NAMESPACE" "NAME" "TYPE" "CLUSTER-IP"];};
        }
      '';
    };

    desktopEntryEnable = mkEnableOption "XDG desktop entry" // {
      default = isLinux;
    };

    settings = mkOption {
      type = yamlFormat.type;
      readOnly = true;
      default = recursiveUpdate {
        k9s = {
          clusters = (mapAttrs (_: cluster: removeAttrs clusters [ "skin" ]));
        };
      } cfg.extraConfig;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "k9s/config.yml" = mkIf (cfg.settings != { }) {
        source = yamlFormat.generate "k9s-config" cfg.settings;
      };

      "k9s/alias.yml" = mkIf (cfg.aliases != { }) {
        source = yamlFormat.generate "k9s-alias" { alias = cfg.aliases; };
      };

      "k9s/plugin.yml" = mkIf (cfg.plugins != { }) {
        source = yamlFormat.generate "k9s-plugin" { plugin = cfg.plugins; };
      };

      "k9s/hotkey.yml" = mkIf (cfg.hotKeys != { }) {
        source = yamlFormat.generate "k9s-hotkey" { hotKey = cfg.hotKeys; };
      };
    } // (mapAttrs' (clusterName: { skin, ... }:
      {
        "k9s/${name}_skin.yml" = {
          source = yamlFormat.generate

        };
      } (filterAttrs (_: cluster: cluster.skin != { }))));

    # https://raw.githubusercontent.com/derailed/k9s/17a61323e155fa193db0a86d8e53238c7852454b/assets/k9s.png
    xdg.desktopEntries.k9s = lib.mkIf desktopEntryEnable {
      name = "k9s";
      genericName = "Kubernetes Console";
      comment = "Kubernetes cluster resource monitor and manager";
      type = "Application";
      exec = getExe cfg.package;
      terminal = true;
      categories = [ "Development" "Utility" "Network" "ConsoleOnly" ];
    };

    xdg.mimeApps.defaultApplications =
      mkIf desktopEntryEnable { "x-scheme-handler/k9s" = "k9s.desktop"; };
  };

}
