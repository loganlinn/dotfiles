{
  imports = [
    ./bufferline.nix
    ./comment.nix
    ./lualine.nix
    ./mini.nix
    ./nvim-autopairs.nix
    ./nvim-filetree.nix
    ./oil.nix
    ./telescope.nix
    ./which-key.nix
  ];

  programs.nixvim.plugins = {
    fugitive.enable = true;
    illuminate.enable = true; # highlight other instances of word
    nix.enable = true;
    surround.enable = true;
  };
}
