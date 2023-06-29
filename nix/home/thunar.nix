{ config
, lib
, pkgs
, ...
}:

with lib;

let
  thunarPlugins = [
    pkgs.xfce.thunar-archive-plugin
    pkgs.xfce.thunar-volman
    pkgs.xfce.thunar-media-tags-plugin
  ];
in
{

  # nixos.services.tumbler.enable = mkDefault true; # thunar thumbnail support for images
  # nixos.services.gvfs.enable = mkDefault true; # thunar mount, trash, and other functionalities

  home.packages = with pkgs; [
    (xfce.thunar.override { inherit thunarPlugins; })
    xfce.exo # thunar "open terminal here"
    xfce.thunar-volman
    xfce.tumbler # thunar thumbnails
    xfce.xfce4-volumed-pulse
    xfce.xfconf # thunar save settings

    # one of the following needed for thunar-archive-plugin
    # see: https://docs.xfce.org/xfce/thunar/archive
    xarchiver
    # gnome.file-roller # Gnome
    # libsForQt5.ark    # KDE
    # mate.engrampa     # MATE
  ] ++ thunarPlugins;

  xdg.configFile.thunar_actions = {
    target = "Thunar/uca.xml";
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
        <action>
          <icon>utilities-terminal</icon>
          <name>Open Terminal Here</name>
          <unique-id>1604472351415438-1</unique-id>
          <command>${getExe pkgs.handlr} launch x-scheme-handler/terminal -- --working-directory %f</command>
          <description></description>
          <patterns>*</patterns>
          <startup-notify/>
          <directories/>
        </action>
      </actions>
    '';
  };

}
