{
  config,
  pkgs,
  lib,
  ...
}:
# https://github.com/drewdeponte/alt
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    homebrew.taps = ["drewdeponte/oss"];
    homebrew.brews = ["drewdeponte/oss/alt"];

    programs.nixvim = {
      extraConfigLua = ''
        function alt_action(opts)
          opts = opts or {}
          return function()
            local command = { opts.alt_executable_path or "/opt/homebrew/bin/alt" }
            -- TODO insert additional args
            table.insert(command, vim.fn.expand("%:p"))
            local finder = require("telescope.finders").new_oneshot_job(command)
            local sorter = require("telescope.config").values.generic_sorter()

            return require("telescope.pickers").new({
              prompt_title = "alternates",
              finder = finder,
              sorter = sorter,
            }):find()
          end
        end

        vim.keymap.set('n', '<leader>.', alt_action())
      '';
    };
  };
}
