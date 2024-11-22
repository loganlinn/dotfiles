{
  programs.nixvim = {
    plugins.bufdelete.enable = true;
    keymaps = [
      {
        key = "<leader>bd";
        action = "<cmd>:bwipeout<cr>"; # does not close split
        options.desc = "Wipeout buffer";
      }
      {
        key = "<leader>bk";
        action = "<cmd>:bwipeout<cr>"; # does not close split
        options.desc = "Wipeout buffer";
      }
    ];
  };
}
