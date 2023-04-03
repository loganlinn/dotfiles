{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    kind
    kpt
    krew # required after install: krew install krew
    kubeconform
    kubectl
    kubectx
    kubernetes-helm
    kustomize
    kuttl
    stern # log tailer
    # (pkgs.callPackage ../../pkgs/kubectl-fzf.nix { })
    (pkgs.callPackage ../../pkgs/kubefwd.nix { })
  ];

  programs.k9s.enable = true;

  # https://raw.githubusercontent.com/derailed/k9s/17a61323e155fa193db0a86d8e53238c7852454b/assets/k9s.png
  xdg.desktopEntries.k9s = lib.mkIf pkgs.stdenv.isLinux {
    name = "k9s";
    genericName = "Kubernetes Console";
    comment = "Kubernetes cluster resource monitor and manager";
    type = "Application";
    exec = "${config.programs.k9s.package}/bin/k9s";
    terminal = true;
    categories = [ "Development" "Utility" "Network" "ConsoleOnly" ];
  };

  xdg.configFile."k9s/plugin.yml".source = ../../../config/k9s/plugin.yml;
  xdg.configFile."k9s/hotkey.yml".source = ../../../config/k9s/hotkey.yml;
  xdg.configFile."k9s/views.yml".source = ../../../config/k9s/views.yml;
  # xdg.configFile."k9s/skins.yml".source = ../../../config/k9s/skins.yml;
}
