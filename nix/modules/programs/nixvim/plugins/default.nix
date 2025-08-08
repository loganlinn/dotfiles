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
      let
        inherit (pkgs) fetchFromGitHub;
        inherit (pkgs.vimUtils) buildVimPlugin;
      in
      with pkgs.vimPlugins;
      [
        fennel-vim
        nfnl
        vim-abolish # i.e. :%Subvert/facilit{y,ies}/building{,s}/g
        vim-caddyfile
        vim-just
        vim-lion # alignment operators
        vim-rsi # readline style insertion
        zoxide-vim
        (buildVimPlugin {
          name = "terraform-nvim";
          src = fetchFromGitHub {
            owner = "mvaldes14";
            repo = "terraform.nvim";
            rev = "0e690df48ac55e6b2794f2aa26fd080d21629216";
            hash = "sha256-O6jhKVuUfzmgK3J4vQ62sytAHus2FvCUAh8bNbkgeKQ=";
          };
          dependencies = [
            config.programs.nixvim.plugins.telescope.package
            nui-nvim
            plenary-nvim
          ];
        })
      ]
      ++ (lib.optional (config.programs.aider.enable or false) { plugin = aider-nvim; });
  };
}
