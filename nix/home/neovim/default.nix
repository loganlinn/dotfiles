{ config
, pkgs
, self
, lib
, ...
}:

let
  inherit (lib) mkOptionDefault;
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
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

  programs.neovim = {
    enable = true;

    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    vimAlias = true;
    viAlias = true;

    extraPackages = with pkgs;[
      gcc
      zig
    ];

    extraPython3Packages = ps: with ps; [ pynvim ];

  };

  # nvim  --headless -c 'autocmd User PackerComplete quitall'
  xdg.configFile."astronvim/lua/user".source = mkOutOfStoreSymlink "${config.my.dotfilesDir}/config/astronvim/lua/user";

  home.activation.astrovim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! [ -d "${config.xdg.configHome}"/nvim/.git ]; then
      ${pkgs.git}/bin/git clone https://github.com/AstroNvim/AstroNvim "${config.xdg.configHome}"/nvim
    fi
  '';
}
