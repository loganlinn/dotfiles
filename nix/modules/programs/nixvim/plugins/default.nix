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
    ./which-key.nix
  ];

  programs.nixvim.plugins = {
    direnv.enable = true;
    fugitive.enable = true;
    gitlinker.enable = true;
    illuminate.enable = true; # highlight other instances of word
    nix.enable = true;
    vim-surround.enable = true;
    trouble.enable = true;
    web-devicons.enable = true;
    qmk.enable = false;
  };
}
