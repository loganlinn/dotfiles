{ config
, pkgs
, self
, lib
, ...
}:

let
  inherit (lib) mkOptionDefault;
in
{
  # LSP servers
  home.packages = with pkgs; [
    deadnix
    gopls
    godef
    luarocks
    nodePackages.bash-language-server
    sumneko-lua-language-server
    rnix-lsp
    statix
    yamllint
  ];

  # home.configFile."nvim".source = fetchFromGitHub {
  #   owner = "NvChad";
  #   repo = "NvChad";
  #   rev = "32b0a00";
  #   hash = "sha256-IfVcysO6LTm7xFv5m7+GExmplj0P+IVGSeoMCT9qvBY=";
  # };

  programs.neovim = {
    enable = true;

    extraPackages = with pkgs;[
      gcc
      zig
    ];

    withNodeJs = true;
    withPython3 = true;

    vimAlias = true;
    viAlias = true;

    coc = mkOptionDefault {
      enable = false;
      settings = {
        "suggest.noselect" = true;
        "suggest.enablePreview" = true;
        "suggest.enablePreselect" = false;
        "suggest.disableKind" = true;
        languageserver = {
          haskell = {
            command = "haskell-language-server-wrapper";
            args = [ "--lsp" ];
            rootPatterns = [
              "*.cabal"
              "stack.yaml"
              "cabal.project"
              "package.yaml"
              "hie.yaml"
            ];
            filetypes = [ "haskell" "lhaskell" ];
          };
        };
      };


    };


    # plugins = with pkgs.vimPlugins; [
    #   vim-commentary
    #   vim-dispatch
    #   vim-easy-align
    #   vim-endwise
    #   vim-eunuch
    #   vim-fireplace
    #   vim-fugitive
    #   vim-pathogen
    #   vim-repeat
    #   vim-rhubarb
    #   vim-rsi
    #   vim-salve
    #   vim-sensible
    #   vim-sexp-mappings-for-regular-people
    #   vim-sleuth
    #   vim-speeddating
    #   vim-surround
    #   vim-unimpaired

    #   # Core
    #   bufferline-nvim
    #   cmp-buffer
    #   cmp-cmdline
    #   cmp-dap
    #   cmp-nvim-lsp
    #   cmp-nvim-lsp-document-symbol
    #   cmp-path
    #   cmp_luasnip
    #   comment-nvim
    #   crates-nvim
    #   dressing-nvim
    #   editorconfig-nvim
    #   gitsigns-nvim
    #   indent-blankline-nvim
    #   leap-nvim
    #   lspkind-nvim
    #   lualine-nvim
    #   luasnip
    #   neo-tree-nvim
    #   noice-nvim
    #   null-ls-nvim
    #   numb-nvim
    #   nvim-cmp
    #   nvim-colorizer-lua
    #   nvim-dap
    #   nvim-dap-ui
    #   nvim-jdtls
    #   nvim-lspconfig
    #   nvim-navic
    #   nvim-notify
    #   nvim-treesitter-textobjects
    #   nvim-treesitter.withAllGrammars
    #   nvim-web-devicons
    #   nvim_context_vt
    #   playground
    #   refactoring-nvim
    #   ron-vim
    #   rust-tools-nvim
    #   telescope-fzf-native-nvim
    #   telescope-nvim
    #   trouble-nvim
    #   which-key-nvim
    #   vim-lastplace
    #   vim-startify
    #   vim-visual-multi

    #   # Language support
    #   vim-nix
    #   vim-markdown
    #   vim-clojure-static
    #   vim-shellcheck
    #   yuck-vim
    #   # vim-kitty-navigator
    #   # pkgs.vimUtils.buildVimPlugin {
    #   #   name = "vim-kitty";
    #   #   src = fetchFromGitHub {
    #   #     owner = "fladson";
    #   #     repo = "vim-kitty";
    #   #     rev = "d4c60f096b751c1462c80cbf42550e29c8cd2983";
    #   #     hash = "sha256-dOz55kUIsrRIuT7UBZaGy8fxpI2zzQL875ooUmZwoY4=";
    #   #   };
    #   # }

    #   # Theme
    #   {
    #     plugin = onedarkpro-nvim;
    #     config = "colorscheme onedark";
    #   }
    # ];

    extraPython3Packages = ps: with ps; [ pynvim ];
  };
}
