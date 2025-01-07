{
  programs.nixvim = {
    plugins.neotest = {
      enable = true;
      adapters.bash.enable = true;
      # adapters.java.enable = true;
      adapters.jest.enable = true;
      # adapters.plenary.enable = true;
      settings = { };
    };
  };
}
