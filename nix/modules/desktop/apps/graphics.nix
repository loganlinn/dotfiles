{ pkgs, ... }:

{

  home.packages = with pkgs; [
    blender
    fstl
    inkscape
  ];

  xdg.desktopEntries.fstl = {
    name = "fstl";
    genericName = "STL viewer";
    comment = "View STL model files";
    type = "Application";
    exec = "${pkgs.fstl}/bin/fstl";
    terminal = false;
    mimeType = [ "model/stl" ];
    categories = [ "Graphics" "3DGraphics" "Viewer" "Qt" ];
  };

}
