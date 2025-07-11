{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.nixvim;
in
{
  imports = [
    # ./notify.nix # replaced with snacks.nix
    # ./nvim-tree.nix # have never gotten this to play nice with auto-session
    # ./zen-mode.nix # replaced with snacks.nix
    ./auto-session.nix
    ./bufferline.nix
    ./claude-code.nix
    ./cmp.nix
    ./comment.nix
    ./conform.nix
    ./early-retirement.nix
    ./fold-preview
    ./git
    ./git-worktree
    ./harpoon.nix
    ./lazydev.nix
    ./lsp
    ./lualine.nix
    ./lz-n
    ./mini.nix
    ./neorepl.nix
    ./neotest.nix
    ./obsidian.nix
    ./oil.nix
    ./project.nix
    ./snacks.nix
    ./supermaven
    ./telescope.nix
    ./treesitter.nix
    ./trouble
    ./ts-actions.nix
    ./typescript-tools.nix
    ./which-key.nix
  ];
  programs.nixvim = {
    plugins = {
      colorizer.enable = true;
      direnv.enable = true;
      firenvim.enable = true;
      helpview.enable = true;
      lazydev.enable = true;
      luasnip.enable = true;
      nix.enable = true;
      noice.enable = true;
      notify.enable = true;
      nvim-autopairs.enable = true;
      nvim-tree.enable = false;
      schemastore.enable = true;
      trouble.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;
      wezterm.enable = true;
    };
    extraPlugins =
      with pkgs.vimPlugins;
      [
        { plugin = fennel-vim; }
        { plugin = nfnl; }
        { plugin = vim-abolish; } # i.e. :%Subvert/facilit{y,ies}/building{,s}/g
        { plugin = vim-just; }
        { plugin = vim-lion; } # alignment operators
        { plugin = vim-rsi; } # readline style insertion
        { plugin = zoxide-vim; }
      ]
      ++ (lib.optional (config.programs.aider.enable or false) { plugin = aider-nvim; });
  };
}
