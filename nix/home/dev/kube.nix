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

  xdg.configFile."k9s/plugin.yml".text = ''
    plugin:
      stern:
        shortCut: Ctrl-L
        confirm: false
        description: "Logs <Stern>"
        scopes:
          - pods
        command: ${pkgs.stern}/bin/stern
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
        command: sh
        background: false
        args:
        - -c
        - "watch -n 5 ${pkgs.kubectl}/bin/kubectl get events --context $CONTEXT --namespace $NAMESPACE --field-selector involvedObject.name=$NAME"
  '';

  # xdg.configFile."k9s/skin.yml".text = ''
  #   # OneDark presets
  #   foreground: &foreground "#abb2bf"
  #   background: &background "#282c34"
  #   black: &black "#080808"
  #   blue: &blue "#61afef"
  #   green: &green "#98c379"
  #   grey: &grey "#abb2bf"
  #   orange: &orange "#ffb86c"
  #   purple: &purple "#c678dd"
  #   red: &red "#e06370"
  #   yellow: &yellow "#e5c07b"
  #   yellow_bright: &yellow_bright "#d19a66"

  #   k9s:
  #     body:
  #       fgColor: *foreground
  #       bgColor: *background
  #       logoColor: *green
  #     prompt:
  #       fgColor: *foreground
  #       bgColor: *background
  #       suggestColor: *orange
  #     info:
  #       fgColor: *grey
  #       sectionColor: *green
  #     dialog:
  #       fgColor: *black
  #       bgColor: *background
  #       buttonFgColor: *foreground
  #       buttonBgColor: *green
  #       buttonFocusFgColor: *black
  #       buttonFocusBgColor: *blue
  #       labelFgColor: *orange
  #       fieldFgColor: *blue
  #     frame:
  #       border:
  #         fgColor: *green
  #         focusColor: *green
  #       menu:
  #         fgColor: *grey
  #         keyColor: *yellow
  #         numKeyColor: *yellow
  #       crumbs:
  #         fgColor: *black
  #         bgColor: *green
  #         activeColor: *yellow
  #       status:
  #         newColor: *blue
  #         modifyColor: *green
  #         addColor: *grey
  #         pendingColor: *orange
  #         errorColor: *red
  #         highlightColor: *yellow
  #         killColor: *purple
  #         completedColor: *grey
  #       title:
  #         fgColor: *blue
  #         bgColor: *background
  #         highlightColor: *purple
  #         counterColor: *foreground
  #         filterColor: *blue
  #     views:
  #       charts:
  #         bgColor: *background
  #         defaultDialColors:
  #           - *green
  #           - *red
  #         defaultChartColors:
  #           - *green
  #           - *red
  #       table:
  #         fgColor: *yellow
  #         bgColor: *background
  #         cursorFgColor: *black
  #         cursorBgColor: *blue
  #         markColor: *yellow_bright
  #         header:
  #           fgColor: *grey
  #           bgColor: *background
  #           sorterColor: *orange
  #       xray:
  #         fgColor: *blue
  #         bgColor: *background
  #         cursorColor: *foreground
  #         graphicColor: *yellow_bright
  #         showIcons: false
  #       yaml:
  #         keyColor: *red
  #         colonColor: *grey
  #         valueColor: *grey
  #       logs:
  #         fgColor: *grey
  #         bgColor: *background
  #         indicator:
  #           fgColor: *blue
  #           bgColor: *background
  #       help:
  #         fgColor: *grey
  #         bgColor: *background
  #         indicator:
  #           fgColor: *blue
  #     '';
}
