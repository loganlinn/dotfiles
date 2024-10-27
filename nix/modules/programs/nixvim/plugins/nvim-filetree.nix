{
  programs.nixvim = {
    plugins.nvim-tree = {
      enable = true;
      git.enable = true;
      git.ignore = false;
      renderer.indentWidth = 1;
      diagnostics.enable = true;
      view.float.enable = true;
      updateFocusedFile.enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>op";
        action = "<cmd>lua require('nvim-tree.api').tree.toggle()<CR>";
        options.desc = "Toggle Tree";
      }
    ];
  };
}
