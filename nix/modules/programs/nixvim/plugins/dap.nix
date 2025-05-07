{
  programs.nixvim = {
    plugins.dap = {
      enable = true;
      settings = { };
    };
    plugins.dap-ui = {
      enable = true;
      settings = { };
    };
  };
}
