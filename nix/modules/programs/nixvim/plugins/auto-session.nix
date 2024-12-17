{
  programs.nixvim = {
    plugins.auto-session = {
      enable = true;
      settings = {
        keys = [
          {
            mode = "n";
            key = "<leader>qs";
            action = "<cmd>SessionSave<cr>";
            options.desc = "Session save";
            options.silent = true;
          }
          {
            mode = "n";
            key = "<leader>qd";
            action = "<cmd>SessionSave<cr>";
            options.desc = "Session delete";
            options.silent = true;
          }
        ];
      };
    };
  };
}
