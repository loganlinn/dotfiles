{ pkgs, ... }:
{
  programs.nixvim = {
    # highlighting languages contained in strings of home-manager config using treesitter. how niche.
    plugins.hmts.enable = true;

    plugins.treesitter = {
      enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        json
        just
        lua
        make
        markdown
        nix
        regex
        toml
        vim
        vimdoc
        xml
        yaml
      ];
      settings = {
        auto_install = false;
        ensure_installed = [
          "git_config"
          "git_rebase"
          "gitattributes"
          "gitcommit"
          "gitignore"
        ];
      };
    };
    plugins.treesitter-context.enable = true;
    plugins.treesitter-context.settings.max_lines = 2;
    plugins.rainbow-delimiters.enable = true;
  };
}
