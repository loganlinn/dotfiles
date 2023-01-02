{ pkgs, ... }:

{

  home.packages = with pkgs; [
    mullvad
    mullvad-vpn
  ];

}
