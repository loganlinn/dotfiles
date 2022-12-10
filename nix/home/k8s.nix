{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    krew # required after install: krew install krew
    kubectl
    kubectx
    kubernetes-helm
    kustomize
    stern
    kind
  ];

  programs.k9s.enable = true;

  xdg.configFile."k9s/skin.yml" = with pkgs; {
    source = ''
      plugin:
        stern:
          shortCut: Ctrl-L
          confirm: false
          description: "Logs <Stern>"
          scopes:
            - pods
          command: ${stern}
          background: false
          args:
            - --tail
            - 50
            - $FILTER
            - -n
            - $NAMESPACE
            - --context
            - $CONTEXT
        watch-events:
          shortCut: Shift-E
          confirm: false
          description: Get Events
          scopes:
          - all
          command: ${sh}
          background: false
          args:
          - -c
          - "watch -n 5 ${kubectl} get events --context $CONTEXT --namespace $NAMESPACE --field-selector involvedObject.name=$NAME"
    '';
  };
}
