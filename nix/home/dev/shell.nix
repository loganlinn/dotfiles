{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    shfmt
    shellcheck
    shellharden
    nodePackages.bash-language-server

    # gum
    # vhs
    # asciinema
    # asciinema-scenario # https://github.com/garbas/asciinema-scenario/
  ];
}
