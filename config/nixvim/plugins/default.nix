{
  imports = [
    ./autopairs.nix
    ./bufferline.nix
    ./comment.nix
    ./filetree.nix
    ./lualine.nix
    ./mini.nix
    ./oil.nix
    ./telescope.nix
    ./which-key.nix
  ];

  plugins.fugitive.enable = true;
  plugins.illuminate.enable = true; # highlight other instances of word
  plugins.nix.enable = true;
  plugins.surround.enable = true;
}
