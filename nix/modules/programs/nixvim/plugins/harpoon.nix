{
  programs.nixvim = {
    plugins.harpoon = {
      enable = false;
      keymaps = {
        addFile = "<leader>bm";
        navFile = {
          "1" = "<leader>b1";
          "2" = "<leader>b2";
          "3" = "<leader>b3";
          "4" = "<leader>b4";
        };
      };
    };
  };
}
