{
  pkgs,
  lib,
  ...
}: let
  dracula = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "kitty";
    rev = "87717a3f00e3dff0fc10c93f5ff535ea4092de70";
    hash = "sha256-78PTH9wE6ktuxeIxrPp0ZgRI8ST+eZ3Ok2vW6BCIZkc=";
  };
in {
  # https://draculatheme.com/kitty
  programs.kitty.extraConfig = ''
    include dracula.conf
  '';
  xdg.configFile."kitty/diff.conf".source = "${dracula}/diff.conf";
  xdg.configFile."kitty/dracula.conf".source = "${dracula}/dracula.conf";
}
