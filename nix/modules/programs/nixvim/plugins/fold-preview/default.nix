{
  pkgs,
  lib,
  ...
}:
{
  programs.nixvim = {
    extraPlugins = [
      pkgs.vimPlugins.fold-preview-nvim
      (pkgs.vimUtils.buildVimPlugin {
        pname = "keymap-amend-nvim";
        version = "b8bf9d820878d5497fdd11d6de55dea82872d98e";
        src = pkgs.fetchFromGitHub {
          owner = "anuvyklack";
          repo = "keymap-amend.nvim";
          rev = "b8bf9d820878d5497fdd11d6de55dea82872d98e";
          hash = "sha256-fjhZLetXo+chDywxukJtuMv15gJgi4c3lwYx+ubOUr4=";
        };
      })
    ];
    extraConfigLua = ''
      local keymap = vim.keymap
      keymap.amend = require('keymap-amend')

      local fold_preview = require('fold-preview')

      fold_preview.setup({
         default_keybindings = false,
      })

      keymap.amend('n', 'K', function(original) if not fold_preview.toggle_preview() then original() end end)
      keymap.amend('n', 'h',  fold_preview.mapping.close_preview_open_fold)
      keymap.amend('n', 'l',  fold_preview.mapping.close_preview_open_fold)
      keymap.amend('n', 'zo', fold_preview.mapping.close_preview)
      keymap.amend('n', 'zO', fold_preview.mapping.close_preview)
      keymap.amend('n', 'zc', fold_preview.mapping.close_preview_without_defer)
      keymap.amend('n', 'zR', fold_preview.mapping.close_preview)
      keymap.amend('n', 'zM', fold_preview.mapping.close_preview_without_defer)
    '';
  };
}
