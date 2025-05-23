{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    jetbrains.idea-community
  ];

  # TODO maybe can reuse settings type from https://github.com/nix-community/home-manager/blob/master/modules/programs/vim.nix
  xdg.configFile."ideavim/ideavimrc".text = ''
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'

    packadd matchit

    set hlsearch
    set ignorecase
    set incsearch
    set smartcase
    set relativenumber

    " use system clipboard
    set clipboard+=unnamed

    " enable native IntelliJ insertion
    set clipboard+=ideaput

    " see https://github.com/JetBrains/ideavim/wiki/ideajoin-examples
    set ideajoin

    set idearefactormode=keep


    map <leader>f <Action>(GotoFile)
    map <leader>g <Action>(FindInPath)
    map <leader>b <Action>(Switcher)
  '';
}
