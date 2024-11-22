{

  programs.nixvim = {
    plugins.snacks = {
      enable = true;
      settings = {
        bigfile.enable = true;
      };
    };
  };
}
