{
  programs.nixvim = {
    plugins.telescope = {
      enable = true;
      extensions = {
        file-browser.enable = true;
        frecency.enable = true;
        fzf-native.enable = true;
        live-grep-args.enable = true;
        # manix.enable = true;
        undo.enable = true;
        ui-select.enable = true;
        # ui-select.settings.codeactions = false;
      };
      settings.defaults = {
        file_ignore_patterns = [
          "^.direnv/"
          "^.git/"
          "^__pycache__/"
          "^node_packages/"
          "^output/"
          "^target/"
        ];
        mappings = {
          i = {
            "<C-h>".__raw = "which_key";
            "<C-g>".__raw = "require('telescope.actions').close";
            "<C-u>".__raw = "false";
          };
        };
      };
      keymaps = {
        "<leader><space>" = "find_files";
        "<leader>:" = "command_history";
        "<leader>'" = "resume";
        "<leader>bb" = "buffers";
        "<leader>bs" = "current_buffer_fuzzy_find";
        "<leader>bt" = "current_buffer_tags";
        "<leader>ff" = "find_files";
        "<leader>fg" = "diagnostics";
        "<leader>cd" = "lsp_definitions";
        "<leader>ct" = "lsp_type_definitions";
        "<leader>cJ" = "lsp_document_symbols";
        "<leader>cj" = "lsp_dynamic_workspace_symbols";
        "<leader>cr" = "lsp_references";
        "<leader>cy" = "lsp_incoming_calls";
        "<leader>cY" = "lsp_outgoing_calls";
        "<leader>cx" = "quickfix";
        "<leader>su" = "undo";
        "<leader>sa" = {
          action = "autocommands";
          options = {
            desc = "Auto Commands";
          };
        };
        "<leader>sb" = {
          action = "current_buffer_fuzzy_find";
          options = {
            desc = "Buffer";
          };
        };
        "<leader>sc" = {
          action = "command_history";
          options = {
            desc = "Command History";
          };
        };
        "<leader>sC" = {
          action = "commands";
          options = {
            desc = "Commands";
          };
        };
        "<leader>ss" = "symbols";
        "<leader>sD" = {
          action = "diagnostics";
          options = {
            desc = "Workspace diagnostics";
          };
        };
        "<leader>sh" = {
          action = "help_tags";
          options = {
            desc = "Help pages";
          };
        };
        "<leader>sH" = {
          action = "highlights";
          options = {
            desc = "Search Highlight Groups";
          };
        };
        "<leader>sk" = {
          action = "keymaps";
          options = {
            desc = "Keymaps";
          };
        };
        "<leader>sM" = {
          action = "man_pages";
          options = {
            desc = "Man pages";
          };
        };
        "<leader>sm" = {
          action = "marks";
          options = {
            desc = "Jump to Mark";
          };
        };
        "<leader>so" = {
          action = "vim_options";
          options = {
            desc = "Options";
          };
        };
        "<leader>uC" = {
          action = "colorscheme";
          options = {
            desc = "Colorscheme preview";
          };
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>";
        options.desc = "Grep Files";
      }
      {
        mode = "n";
        key = "<leader>*";
        action = "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_visual_selection()<CR>";
        options.desc = "Grep Selection";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action.__raw = ''
          function()
             require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h") })
            end
        '';
        options.desc = "Search current directory";
      }

      # prefix: <leader>f
      {
        mode = "n";
        key = "<leader>fd";
        action.__raw = ''
          function()
            require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
          end
        '';
        options.desc = "Find current directory";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>lua require('telescope.builtin').diagnostics()<CR>";
        options.desc = "Find Diagnostics";
      }

      # prefix: <leader>g
      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>Telescope git_branches<CR>";
        options.desc = "Git files";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>Telescope git_status<CR>";
        options.desc = "Git stash";
      }
      {
        mode = "n";
        key = "<leader>gt";
        action = "<cmd>Telescope git_stash<CR>";
        options.desc = "Git stash";
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = "<cmd>Telescope git_commits<CR>";
        options.desc = "Git commits";
      }
      {
        mode = "n";
        key = "<leader>gf";
        action = "<cmd>Telescope git_files<CR>";
        options.desc = "Git files";
      }

      # prefix: <leader>h
      {
        mode = "n";
        key = "<leader>ha";
        action = ''<cmd>Telescope autocommands<CR>'';
        options.desc = "autocommands";
      }
      {
        mode = "n";
        key = "<leader>hb";
        action = ''<cmd>Telescope builtins<CR>'';
        options.desc = "builtins";
      }
      {
        mode = "n";
        key = "<leader>hc";
        action = "<cmd>Telescope commands<CR>";
        options.desc = "commands";
      }
      {
        mode = "n";
        key = "<leader>hk";
        action = ''<cmd>Telescope keymap<CR>'';
        options.desc = "keymaps";
      }
      {
        mode = "n";
        key = "<leader>ht";
        action = "<cmd>lua require('telescope.builtin').help_tags()<CR>";
        options.desc = "help_tags";
      }
      {
        mode = "n";
        key = "<leader>hT";
        action = ''<cmd>Telescope filetypes<CR>'';
        options.desc = "filetypes";
      }
      {
        mode = "n";
        key = "<leader>ho";
        action = ''<cmd>Telescope vim_options<CR>'';
        options.desc = "vim_options";
      }
      {
        mode = "n";
        key = "<leader>hW";
        action = "<cmd>Telescope man_pages<CR>";
        options.desc = "man_pages";
      }
    ];
  };
}
