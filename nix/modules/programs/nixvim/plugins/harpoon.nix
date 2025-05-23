{pkgs, ...}: {
  programs.nixvim = {
    plugins.harpoon = {
      enable = true;
      package = pkgs.vimPlugins.harpoon2;
      enableTelescope = true;
    };
  };
}
