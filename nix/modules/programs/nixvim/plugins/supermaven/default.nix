{
  inputs,
  pkgs,
  lib,
  ...
}: let
  inherit (import ../../helpers.nix {inherit lib;}) buildVimPlugin;
in {
  programs.nixvim = {
    extraPlugins = [
      pkgs.vimPlugins.supermaven-nvim
      # # TODO build vim plugin directly from inputs.supermaven-nvim instead of referencing same rev/hash
      # {
      #   plugin = buildVimPlugin pkgs {
      #     owner = "supermaven-inc";
      #     repo = "supermaven-nvim";
      #     rev = inputs.supermaven-nvim.rev;
      #     hash = inputs.supermaven-nvim.narHash;
      #   };
      # }
    ];
    extraConfigLua = builtins.readFile ./init.lua;
  };
}
