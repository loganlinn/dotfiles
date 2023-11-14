{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    environment.systemPackages = with pkgs; [
      fzf
      xclip
    ];
    programs.vim = {
      defaultEditor = !config.programs.neovim.defaultEditor;
      package = pkgs.vim-full.customize {
        name = "vim";
        vimrcConfig.packages.myPlugins = with pkgs.vimPlugins; {
          start = [
            editorconfig-vim
            fzf-vim
            vim-commentary
            vim-eunuch
            vim-fugitive
            vim-gitgutter
            vim-lastplace
            vim-nix
            vim-repeat
            vim-sensible
            vim-sleuth
            vim-surround
            vim-unimpaired
          ];
          opt = [ ];
        };
        vimrcConfig.customRC = ''
          let mapleader = "\<Space>"

          " system clip
          set clipboard=unnamed

          " yank to system clipboard without motion
          nnoremap <Leader>y "+y

          " yank line to system clipboard
          nnoremap <Leader>yl "+yy

          " yank file to system clipboard
          nnoremap <Leader>yf gg"+yG

          " paste from system clipboard
          nnoremap <Leader>p "+p
        '';
      };
    };
  };
}
