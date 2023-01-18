{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.writeShellApplication {
  name = "i3-draw";
  runtimeInputs = with pkgs; [ i3 hacksaw ];
  text = ''
    hacksaw -n | {
        IFS=+x read -r w h x y

        w=$((w + w % 2))
        h=$((h + h % 2))

        i3-msg floating enable
        i3-msg resize set width "$w" px height "$h" px
        i3-msg move position "$x" px "$y" px
    }
  '';
}
