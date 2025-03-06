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
    ./auto-session.nix
    ./bufferline.nix
    ./cmp.nix
    ./comment.nix
    ./conform.nix
    ./dadbod.nix
    ./early-retirement.nix
    ./git
    ./harpoon.nix
    ./lazydev.nix
    ./lsp
    ./lualine.nix
    ./mini.nix
    ./neorepl.nix
    ./neotest.nix
    # ./notify.nix # replaced with snacks.nix
    ./nvim-tree.nix
    ./obsidian.nix
    ./oil.nix
    ./project.nix
    ./snacks.nix
    ./supermaven
    ./telescope.nix
    ./treesitter.nix
    ./typescript-tools.nix
    ./which-key.nix
    # ./zen-mode.nix # replaced with snacks.nix
  ];
  programs.nixvim = {
    plugins = {
      # qmk.enable = false;
      # sniprun.enable = true;
      # spectre.enable = true;
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
      schemastore.enable = true;
      trouble.enable = true;
      vim-dadbod-completion.enable = true;
      vim-dadbod-ui.enable = true;
      vim-dadbod.enable = true;
      vim-surround.enable = true;
      web-devicons.enable = true;
      wezterm.enable = true;
    };
    extraPlugins = with pkgs.vimPlugins; [
      { plugin = fennel-vim; }
      { plugin = nfnl; }
      { plugin = vim-abolish; }
      { plugin = vim-just; }
      { plugin = vim-lion; }
      { plugin = zoxide-vim; }
    ];
    keymaps = [
      {
        mode = "n";
        key = "<leader>od";
        action = "<cmd>DBUIToggle<cr>";
      }
    ];
  };
}
