{
  config,
  pkgs,
  ...
}:
{
  programs.nixvim = {
    plugins.nui.enable = true;
    extraPlugins = [
      {
        plugin = pkgs.vimUtils.buildVimPlugin rec {
          pname = "ts-actions-nvim";
          version = "18319edd51f6d7e9a246ab7afdbd7401e25c79e8";
          src = pkgs.fetchFromGitHub {
            owner = "jordangarcia";
            repo = "ts-actions.nvim";
            rev = version;
            hash = "sha256-cGFPRBJoLXjbK+DiT8kpcU7w/PVok5VQDSOvbXy4ItA=";
          };
          dependencies = [ config.programs.nixvim.plugins.nui.package ];
        };
      }
    ];
    keymaps = [
      {
        mode = "n";
        key = "<leader>cp";
        action.__raw = ''
          function() require("ts-actions").prev() end
        '';
        options = {
          desc = "Next ts-action";
        };
      }
      {
        mode = "n";
        key = "<leader>cn";
        action.__raw = ''
          function() require("ts-actions").next() end
        '';
        options = {
          desc = "Next ts-action";
        };
      }
    ];
    # TODO make this lazy
    extraConfigLua = ''
      local ts_priority_f = {
        { key = "f", pattern = "^update import", order = 102 },
        { key = "f", pattern = "^add import", order = 101 },
        { key = "f", pattern = "^fix this", order = 101 },
        { key = "f", pattern = "^add async modifier", order = 100 },
        { key = "f", pattern = "^change spelling", order = 100 },
        { key = "f", pattern = "^remove unused", order = 100 },
        { key = "f", pattern = "^prefix .* with an underscore", order = 100 },
        { key = "f", pattern = "^update the dependencies array", order = 100 },
        { key = "F", pattern = "^fix all", order = 99 },
        { key = "d", pattern = "disable .* for this line", order = 99 },
        { key = "D", pattern = "disable .* entire file", order = 98 },
      }
      require("ts-actions").setup {
        ---@type table<string, { pattern: string, key: string, order?: integer }[]>
        priority = {
          ["typescript"] = ts_priority_f,
          ["typescriptreact"] = ts_priority_f,
        },
        severity = {
          ["typescriptreact"] = vim.diagnostic.severity.ERROR,
          ["typescript"] = vim.diagnostic.severity.ERROR,
          ["lua"] = vim.diagnostic.severity.WARN,
        },
        ---@param action LocalCodeAction
        filter_function = function(action)
          -- Check if title exists and contains "refactor."
          if type(action.kind) == "string" and action.kind:find "^refactor%." then
            return false
          end

          if action.title:match "missing function declaration" then
            return false
          end
          -- Default to false if none of the conditions are met
          return true
        end,
      }
    '';
  };
}
