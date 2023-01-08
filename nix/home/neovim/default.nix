{
  config,
  pkgs,
  self,
  lib,
  ...
}: {
  # LSP servers
  home.packages = with pkgs; [
    deadnix
    gopls
    godef
    luarocks
    # nodePackages.eslint
    # nodePackages.typescript
    # nodePackages.typescript-language-server
    # nodePackages.vscode-langservers-extracted
    # nodePackages.remark-cli
    # nodePackages.pyright
    nodePackages.bash-language-server
    sumneko-lua-language-server
    rnix-lsp
    statix
    yamllint
  ];

  programs.neovim = {
    enable = true;

    vimAlias = true;
    viAlias = true;

    extraConfig = ''
      colorscheme catppuccin " catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
    '';

    plugins = with pkgs.vimPlugins; [
      vim-commentary
      vim-dispatch
      vim-easy-align
      vim-endwise
      vim-eunuch
      vim-fireplace
      vim-fugitive
      vim-pathogen
      vim-repeat
      vim-rhubarb
      vim-rsi
      vim-salve
      vim-sensible
      vim-sexp-mappings-for-regular-people
      vim-sleuth
      vim-speeddating
      vim-surround
      vim-unimpaired

      # Themes
      catppuccin-nvim
      tokyonight-nvim

      # Core
      bufferline-nvim
      cmp-buffer
      cmp-cmdline
      cmp-dap
      cmp-nvim-lsp
      cmp-nvim-lsp-document-symbol
      cmp-path
      cmp_luasnip
      comment-nvim
      crates-nvim
      dressing-nvim
      editorconfig-nvim
      gitsigns-nvim
      indent-blankline-nvim
      leap-nvim
      lspkind-nvim
      lualine-nvim
      luasnip
      neo-tree-nvim
      noice-nvim
      null-ls-nvim
      numb-nvim
      nvim-cmp
      nvim-colorizer-lua
      nvim-dap
      nvim-dap-ui
      nvim-jdtls
      nvim-lspconfig
      nvim-navic
      nvim-notify
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      nvim_context_vt
      playground
      refactoring-nvim
      ron-vim
      rust-tools-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      trouble-nvim
      which-key-nvim
      vim-lastplace
      vim-startify
      vim-visual-multi

      # Language support
      vim-nix
      vim-markdown
      vim-clojure-static
      vim-shellcheck
    ];

    extraPython3Packages = ps: with ps; [pynvim];
  };
}
