{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # htmlq # jq for html
    # html2text
    dasel
    jless
    jq
    taplo # toml
    yaml-language-server
    yamllint
    yq-go
  ];
}
