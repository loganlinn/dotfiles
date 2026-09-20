{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    kind
    krew # note: one time bootstrap may be needed: krew install krew
    kubecolor
    kubeconform
    kubectl
    kubectl-images
    kubectl-tree
    kubernetes-helm
    kubie
    kustomize
    stern
    # kuttl  # testing framework
    # velero # backup resources and volumes
  ];

  home.shellAliases = {
    kubectl = "kubecolor";
    k = "kubectl";

    kk = "kustomize";
    kkb = "kk build";

    ku = "kubie";
    kctx = "ku ctx";
    kns = "ku ns";
    kexec = "ku exec";

    klist = ''kubectl get "$@" --no-headers -o custom-columns=":metadata.name"'';
  };

  home.sessionPath = [
    "$HOME/.krew/bin"
  ];

  my.shellInitExtra = ''
    source <(kubie generate-completion)
  '';

  # mise.toml manages config/k9s; do not generate files at the same paths.
  programs.k9s.enable = true;

  xdg.desktopEntries = lib.optionalAttrs pkgs.stdenv.isLinux {
    k9s = {
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
  };
  xdg.configFile = {
    # Out-of-store so `eks-kubeconfig` reads the live repo file; the tool only
    # knows about $XDG_CONFIG_HOME/eks-kubeconfig, not the dotfiles layout.
    "eks-kubeconfig".source =
      config.lib.file.mkOutOfStoreSymlink "${config.my.flakeDirectory}/config/eks-kubeconfig";
  };
}
