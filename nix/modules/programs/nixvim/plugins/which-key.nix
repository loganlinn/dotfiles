{pkgs, ...}: {
  programs.nixvim = {
    plugins.which-key = {
      enable = true;
      settings = {
        preset = "helix";
      };
    };
  };
}
