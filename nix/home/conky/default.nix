{ config, lib, pkgs, ... }:

let
in
{
  home.packages = with pkgs; [
    conky
  ];

  xdg.configFile."conky/frappe.conf".source = ./frappe.conf;
  xdg.configFile."conky/latte.conf".source = ./latte.conf;
  xdg.configFile."conky/macchiato.conf".source = ./macchiato.conf;
  xdg.configFile."conky/mocha.conf".source = ./mocha.conf;
}
