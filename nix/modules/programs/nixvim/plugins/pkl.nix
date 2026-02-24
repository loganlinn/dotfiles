{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.lib.nixvim.lua) toLuaObject;
in
{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      grammarPackages = [
        pkgs.vimPlugins.nvim-treesitter.builtGrammars.pkl
      ];
    };
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "pkl-neovim";
        src = pkgs.fetchFromGitHub {
          owner = "apple";
          repo = "pkl-neovim";
          rev = "d5910d7daa86b27d687727f9d9758abcb7c425d7";
          hash = "sha256-kFrGRFbhkwoqfa9YdYc28gc89of1eZTmPFQv276t/fE=";
        };
      })
    ];
    extraConfigLua = ''
      vim.g.pkl_neovim = ${
        toLuaObject {
          start_command = [
            (lib.getExe pkgs.temurin-bin-25)
            "-jar"
            (pkgs.fetchurl {
              url = "https://github.com/apple/pkl-lsp/releases/download/0.5.3/pkl-lsp-0.5.3.jar";
              hash = "sha256-oswF10l3ql60GHV7OiHOjhV/7c9ZxZmJ4Xt/3dLlgUs=";
            })
          ];
        }
      }
    '';
  };
}
