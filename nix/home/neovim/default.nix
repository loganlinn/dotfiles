{ config, pkgs, self, lib, ... }:

let
  inherit (lib) mkOptionDefault;
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
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

    extraPackages = with pkgs; [ gcc zig ];

    extraPython3Packages = ps: with ps; [ pynvim ];

  };

  # nvim  --headless -c 'autocmd User PackerComplete quitall'
  xdg.configFile."astronvim/lua/user".source =
    mkOutOfStoreSymlink "${config.my.dotfilesDir}/config/astronvim/lua/user";

  home.activation.astrovim = let
    nvimDir = if config.xdg.enable then
      "${config.xdg.configHome}/nvim"
    else
      "${config.home.homeDirectory}/.config/nvim";
  in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! [[ -d ${nvimDir}/.git ]]; then
      mkdir -p "$(dirname "${nvimDir}")"
      ${pkgs.git}/bin/git clone https://github.com/AstroNvim/AstroNvim "${nvimDir}"
    fi
  '';
}
