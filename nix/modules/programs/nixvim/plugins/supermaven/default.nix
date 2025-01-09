{ pkgs, lib, ... }:

let
  inherit (import ../../helpers.nix { inherit lib; }) buildVimPlugin;
in
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = buildVimPlugin pkgs {
          owner = "supermaven-inc";
          repo = "supermaven-nvim";
          rev = "07d20fce48a5629686aefb0a7cd4b25e33947d50";
          hash = "sha256-1z3WKIiikQqoweReUyK5O8MWSRN5y95qcxM6qzlKMME=";
        };
      }
    ];
    extraConfigLua = builtins.readFile ./init.lua;
  };
}
