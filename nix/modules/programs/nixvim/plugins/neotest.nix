{
  programs.nixvim = {
    plugins.neotest = {
      enable = true;
      # adapters.go.enable = true;
      # adapters.java.enable = true;
      # adapters.plenary.enable = true;
      # adapters.rust.enable = true;
      adapters.bash.enable = true;
      adapters.jest.enable = true;
      adapters.python.enable = true;
      settings = { };
    };
  };
}
