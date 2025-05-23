{
  programs.nixvim = {
    plugins.oil = {
      enable = true;
      settings = {
        columns = ["icon"];
        use_default_keymaps = true;
        # keymaps = {
        #   "<C-c>" = false;
        #   "<C-l>" = false;
        #   "<C-r>" = "actions.refresh";
        #   "<leader>qq" = "actions.close";
        #   "y." = "actions.copy_entry_path";
        # };
        delete_to_trash = true;
        skip_confirm_for_simple_edits = true;
        view_options = {
          show_hidden = true;
        };
        win_options = {
          concealcursor = "ncv";
          conceallevel = 3;
          cursorcolumn = false;
          foldcolumn = "0";
          list = false;
          signcolumn = "no";
          spell = false;
          wrap = false;
        };
      };
    };
  };
}
