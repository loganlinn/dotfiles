{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vala
    vala-lint
    vala-language-server

    meson
    stdenv
    pkg-config
    gettext
    glib
    glibc
    gobject-introspection
    cairo
  ];
}
