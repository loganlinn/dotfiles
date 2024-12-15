{ pkgs, ... }:

let
  supermaven-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "supermaven-nvim";
    version = "2024-10-07";
    src = pkgs.fetchFromGitHub {
      owner = "supermaven-inc";
      repo = "supermaven-nvim";
      rev = "07d20fce48a5629686aefb0a7cd4b25e33947d50";
      sha256 = "1h9h98wsnfhkfdmdxjvr2d4idhrvp4i56pp4q6l0m4d2i0ldcgfp";
    };
    meta.homepage = "https://github.com/supermaven-inc/supermaven-nvim/";
  };
in
{
  programs.nixvim = {
    extraPlugins = [ supermaven-nvim ];
    extraConfigLua = builtins.readFile ./init.lua;
  };
}
