{
  programs.nixvim = {
    plugins.obsidian = {
      enable = true;
      settings = {
        completion = {
          min_chars = 2;
          nvim_cmp = true;
        };
      };
    };
  };
}
