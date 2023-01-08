{
  config,
  pkgs,
  self,
  lib,
  ...
}: {
  # move to programs.neovim.extraPackages?
  home.packages = with pkgs; [
    deadnix
    gopls
    # gotools # > error: collision between `/nix/store/czca9a081q3dpd8qp5nzqz2581pw7336-ruby-2.7.6/bin/bundle' and `/nix/store/54v51yb5xzambp18nglljrlsqnn2k1z8-gotools-0.1.10/bin/bundle'
    godef
    luarocks
    # nodePackages.eslint
    # nodePackages.typescript
    # nodePackages.typescript-language-server
    # nodePackages.vscode-langservers-extracted
    # nodePackages.remark-cli
    # nodePackages.pyright
    # nodePackages.bash-language-server
    sumneko-lua-language-server
    rnix-lsp
    statix
    yamllint
  ];

  programs.neovim = {
    enable = true;

    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # a disciple of tpope
      vim-sensible
      vim-pathogen
      vim-dispatch
      vim-repeat
      vim-surround
      vim-unimpaired
      vim-commentary
      vim-easy-align
      vim-speeddating
      vim-eunuch
      vim-sleuth
      vim-endwise
      vim-rsi
      vim-salve
      vim-fireplace
      vim-sexp-mappings-for-regular-people

      vim-fugitive
      vim-rhubarb
      vim-gist

      vim-startify

      # Themes
      tokyonight-nvim
      sonokai
      dracula-vim
      gruvbox
      papercolor-theme
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup {
            options = {
              theme = 'tokyonight'
            }
          }
        '';
      }

      # Languages
      vim-nix
      vim-markdown
      vim-clojure-static
      vim-shellcheck

      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.vimPlugins.nvim-tree-lua
      {
        plugin = pkgs.vimPlugins.vim-startify;
        config = "let g:startify_change_to_vcs_root = 0";
      }
    ];

    extraPython3Packages = ps: with ps; [ pynvim ];
  };

  # programs.neovim = {
  #   enable = true;
  #   withNodeJs = false;
  #   vimAlias = true;
  #   withPython3 = true;
  #   extraPackages = with pkgs; [
  #     deadnix
  #     go
  #     gopls
  #     gotools
  #     godef
  #     luarocks
  #     nodePackages.eslint
  #     nodePackages.typescript
  #     nodePackages.typescript-language-server
  #     nodePackages.vscode-langservers-extracted
  #     nodePackages.remark-cli
  #     nodePackages.pyright
  #     nodePackages.bash-language-server
  #     sumneko-lua-language-server
  #     rnix-lsp
  #     statix
  #     yamllint
  #   ];
  #   extraConfig = ''
  #     runtime _init.lua
  #   '';
  #   plugins = with pkgs.vimPlugins; [
  #     packer-nvim

  #     nvim-cmp
  #     cmp-buffer
  #     cmp_luasnip
  #     cmp-nvim-lsp
  #     cmp-treesitter
  #     cmp-path

  #     nvim-lspconfig
  #     (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
  #     luasnip
  #     playground
  #     vim-surround
  #     targets-vim
  #     vim-gitgutter
  #     vim-rsi
  #     nvim-treesitter-textobjects
  #     conflict-marker-vim
  #     vim-jsonnet
  #     vim-pencil
  #   ];
  # };
}
