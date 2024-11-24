{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.fugitive.enable = true;
    plugins.gitlinker.enable = true;
    plugins.lazygit.enable = true;
    extraPlugins = with pkgs.vimPlugins; [ vim-rhubarb ]; # Enables :GBrowse from fugitive.vim to open GitHub URLs.
    keymaps = [
      # prefix: <leader>g
      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>Telescope git_branches<CR>";
        options.desc = "Git files";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>Telescope git_status<CR>";
        options.desc = "Git stash";
      }
      {
        mode = "n";
        key = "<leader>gt";
        action = "<cmd>Telescope git_stash<CR>";
        options.desc = "Git stash";
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = "<cmd>Telescope git_commits<CR>";
        options.desc = "Git commits";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>gf";
        action = "<cmd>Telescope git_files<CR>";
        options.desc = "Git files";
      }
      {
        mode = "n";
        key = "<leader>gS";
        action = "<cmd>Gwrite<cr>";
        options.desc = "Stage file";
      }
    ];
  };
}
