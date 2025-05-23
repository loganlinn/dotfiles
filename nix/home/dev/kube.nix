{
  config,
  lib,
  pkgs,
  ...
}: {
  home.shellAliases = {
    k = "kubectl";
    kctx = "kubectx";
    kk = "kustomize";
    kkb = "kustomize build";
    know = "kzf nodes";
    kcm = "kzf configmaps";
    kns = "kzf namespaces";
    kpo = "kzf pods";
    ksvc = "kzf services";
    kpvc = "kzf persistentvolumeclaims";
    kpv = "kzf persistentvolumes";
    kdeploy = "kzf deployments";
    kds = "kzf daemonsets";
    krs = "kzf replicasets";
    ksts = "kzf statefulsets";
    kcrd = "kzf customresourcedefinitions";
    kjobs = "kzf jobs";
    kcj = "kzf cronjobs";
  };

  home.packages = with pkgs; [
    kind
    krew # required after install: krew install krew
    kubeconform
    kubectl
    kubectl-tree
    kubectl-images
    kubectx
    kubernetes-helm
    kustomize
    kuttl
    stern # log tailer
    minikube
    # (pkgs.callPackage ../../pkgs/kubectl-fzf.nix { })
    (writeShellApplication {
      name = "kzf";
      runtimeInputs = [
        kubectl
        fzf
      ];
      text = ''
        kubectl get "$@" --no-headers -o custom-columns=":metadata.name" |
        fzf --exit-0 --header "$*"
      '';
    })
  ];

  programs.k9s.enable = true;
  xdg.desktopEntries.k9s = lib.mkIf pkgs.stdenv.isLinux {
    name = "k9s";
    genericName = "Kubernetes Console";
    comment = "Kubernetes cluster resource monitor and manager";
    type = "Application";
    exec = "${config.programs.k9s.package}/bin/k9s";
    terminal = true;
    categories = [
      "Development"
      "Utility"
      "Network"
      "ConsoleOnly"
    ];
  };
  xdg.configFile."k9s/hotkey.yml".source = ../../../config/k9s/hotkey.yml;

  xdg.configFile."k9s/views.yml".source = (pkgs.formats.yaml {}).generate "k9s-view" {
    k9s = {
      views = {
        "v1/namespaces" = {
          columns = [
            "NAME"
            "STATUS"
            "AGE"
          ];
        };
      };
    };
  };

  xdg.configFile."k9s/plugin.yml".source = (pkgs.formats.yaml {}).generate "k9s-plugin" {
    plugin = {
      debug = {
        command = "${
          pkgs.writeShellApplication {
            name = "k9s-debug";
            runtimeInputs = with pkgs; [
              kubectl
              coreutils
              gum
              fzf
            ];
            text = ''
              NAMESPACE=''${1-}
              POD=''${2-}
              TARGET=''${3-}
              IMAGE=''${4-}

              _choose_resource() {
                kubectl get "$@" --output=wide |
                  fzf --exit-0 --select-1 --header-lines=1 |
                  awk '{ print $1 }'
              }

              if [[ -z $NAMESPACE ]]; then
                NAMESPACE=$(_choose_resource namespace)
              fi

              if [[ -z $POD ]]; then
                POD=$(_choose_resource po --namespace="$NAMESPACE")
              fi

              if [[ -z $TARGET ]]; then
                TARGET=$(
                  kubectl get pod "$POD" --namespace="$NAMESPACE" -o jsonpath='{.spec.containers[*].name}' |
                    tr ' ' '\n' |
                    fzf --exit-0 --header "Target container"
                )
              fi

              if [[ -z $IMAGE ]]; then
                IMAGE=$(gum input --prompt "IMAGE: " --value="nicolaka/netshoot")
              fi

              _kubectl_opts=(debug -it "$POD" --namespace="$NAMESPACE" --target="$TARGET" --image="$IMAGE" --share-processes -- bash)

              gum style \
                --border double --width 50 --margin "1 2" --padding "2 4" \
                "kubectl ''${_kubectl_opts[*]}"

              if gum confirm "Proceed?"; then
                kubectl "''${_kubectl_opts[@]}"
              fi
            '';
          }
        }/bin/k9s-debug";
        args = [
          "$NAMESPACE"
          "$POD"
          "$NAME"
        ];
        background = false;
        confirm = true;
        description = "Add debug container";
        scopes = ["containers"];
        shortCut = "Shift-D";
      };

      tree = {
        shortCut = "Shift+T";
        command = "${pkgs.kubectl-tree}/bin/kubectl-tree";
        args = [
          "--kubeconfig"
          "$KUBECONFIG"
          "--context"
          "$CONTEXT"
          "--cluster"
          "$CLUSTER"
          "--user"
          "$USER"
          "--namespace"
          "$NAMESPACE"
          "$GROUPS"
          "$NAME"
        ];
        scopes = ["all"]; # TODO revisit
      };

      images = {
        shortCut = "Ctrl+I";
        command = "${pkgs.kubectl-tree}/bin/kubectl-tree";
        args = [
          "--kubeconfig"
          "$KUBECONFIG"
          "--context"
          "$CONTEXT"
          "--user"
          "$USER"
          "--namespace"
          "$NAMESPACE"
          "--unique"
          "$FILTER"
        ];
        scopes = ["all"]; # TODO revisit
      };

      dive = {
        args = ["$COL-IMAGE"];
        background = false;
        command = "dive";
        confirm = false;
        description = "Dive image";
        scopes = ["containers"];
        shortCut = "Shift+X";
      };

      stern = {
        args = [
          "--tail"
          50
          "$FILTER"
          "--namespace"
          "$NAMESPACE"
          "--context"
          "$CONTEXT"
          "--exclude"
          "io.opentelemetry.exporter.logging.LoggingMetricExporter"
        ];
        background = false;
        command = "${pkgs.stern}/bin/stern";
        confirm = false;
        description = "Logs <Stern>";
        scopes = [
          "pods"
          "jobs"
          "daemonsets"
          "statefulsets"
        ];
        shortCut = "Ctrl-L";
      };

      watch-events = {
        command = "kubectl";
        args = [
          "--context"
          "$CONTEXT"
          "--namespace"
          "$NAMESPACE"
          "get"
          "events"
          "--watch"
        ];
        background = false;
        confirm = false;
        description = "Get Events";
        scopes = ["all"];
        shortCut = "Shift-E";
      };
    };
  };

  # my.k9s = {
  #   enable = true;

  #   hotKeys = {
  #     shift-0 = {
  #       command = "namespaces";
  #       description = "View Namespaces";
  #       shortCut = "Shift-0";
  #     };
  #     shift-1 = {
  #       command = "pods";
  #       description = "View Pods";
  #       shortCut = "Shift-1";
  #     };
  #     shift-2 = {
  #       command = "configmaps";
  #       description = "View ConfigMaps";
  #       shortCut = "Shift-2";
  #     };
  #     shift-3 = {
  #       command = "secrets";
  #       description = "View Secrets";
  #       shortCut = "Shift-3";
  #     };
  #     shift-4 = {
  #       command = "services";
  #       description = "View Services";
  #       shortCut = "Shift-4";
  #     };
  #     shift-5 = {
  #       command = "deployments";
  #       description = "View Deployments";
  #       shortCut = "Shift-5";
  #     };
  #     shift-6 = {
  #       command = "sts";
  #       description = "View StatefulSets";
  #       shortCut = "Shift-6";
  #     };
  #     shift-7 = {
  #       command = "ds";
  #       description = "View DaemonSets";
  #       shortCut = "Shift-7";
  #     };
  #     shift-8 = {
  #       command = "instrumentations";
  #       description = "View Instrumentations";
  #       shortCut = "Shift-8";
  #     };
  #     shift-9 = {
  #       command = "otelcols";
  #       description = "View OpenTelemetryCollectors";
  #       shortCut = "Shift-9";
  #     };
  #   };
  # };
}
