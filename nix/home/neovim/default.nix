{ nix-colors
, config
, pkgs
, lib
, ...
}:

{
  imports = [ ../astronvim.nix ];

  programs.neovim = {
    enable = true;

    defaultEditor = !config.services.emacs.defaultEditor;
    withNodeJs = true;
    withPython3 = true;
    vimAlias = true;
    viAlias = true;

    extraPackages = with pkgs; [ gcc zig ];

    extraPython3Packages = ps: with ps; [ pynvim ];
  };

  my.astronvim.enable = true;

  # LSP servers
  home.packages = with pkgs; [
    deadnix
    gopls
    godef
    luarocks
    nodePackages.bash-language-server
    sumneko-lua-language-server
    rnix-lsp
    statix
    yamllint
  ];

  xdg.dataFile."nvim/runtime/colors/nix-colors.vim".source =
    let
      nixColorsLib = nix-colors.lib.contrib { inherit pkgs; };
      vimTheme = nixColorsLib.vimThemeFromScheme { scheme = config.colorScheme; };
    in
    vimTheme.outPath;
}
