{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.lnav ];
  # xdg.configFile."lnav/configs/kubernetes/default.json".source = ./configs/default/kube-url-scheme.json;
  # xdg.configFile."lnav/scripts/kube-url-handler.lnav".source = ./scripts/kube-url-handler.lnav;
}
