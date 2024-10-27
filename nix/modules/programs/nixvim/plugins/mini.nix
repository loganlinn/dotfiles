{
  programs.nixvim = {
    plugins.mini = {
      enable = true;
      # mockDevIcons = true;
      modules = {
        ai = {
          n_lines = 50;
          search_method = "cover_or_next";
        };
        surround = { };
      };
    };
  };
}
