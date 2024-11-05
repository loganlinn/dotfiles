{
  imports = [
    ./bufferline.nix
    ./comment.nix
    ./conform.nix
    ./lualine.nix
    ./lsp
    ./mini.nix
    ./nvim-autopairs.nix
    ./nvim-filetree.nix
    ./oil.nix
    ./telescope.nix
    ./treesitter.nix
    ./which-key.nix
  ];

  programs.nixvim.plugins = {
    direnv.enable = true;
    fugitive.enable = true;
    gitlinker.enable = true;
    illuminate.enable = true; # highlight other instances of word
    nix.enable = true;
    qmk.enable = false;
    trouble.enable = true;
    typescript-tools.enable = true;
    vim-surround.enable = true;
    web-devicons.enable = true;
    # yanky.enable = true;

    smart-splits = {
      enable = false;
    };

    project-nvim = {
      enable = true;
      enableTelescope = true;
      settings = {
        detection_methods = [
          "lsp"
          "pattern"
        ];
        patterns = [
          ".git"
          "_darcs"
          ".hg"
          ".bzr"
          ".svn"
          "Makefile"
          "package.json"
          "deps.edn"
        ];
        scope_chdir = "tab";
        show_hidden = true;
        silent_chdir = false;
      };
    };
  };
}
