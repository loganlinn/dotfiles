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
            "<C-g>" = {
              __raw = "require('telescope.actions').close";
            };
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
        key = "<leader>'";
        action = "<cmd>Telescope resume<CR>";
        options.desc = "Resume search";
      }

      # prefix: <leader>b
      {
        mode = "n";
        key = "<leader>bb";
        action = "<cmd>lua require('telescope.builtin').buffers()<CR>";
        options.desc = "Find Buffer";
      }
      {
        mode = "n";
        key = "<leader>bs";
        action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
        options.desc = "Find Buffer";
      }
      {
        mode = "n";
        key = "<leader>bt";
        action = "<cmd>Telescope current_buffer_tags<CR>";
        options.desc = "Find Buffer";
      }

      # prefix: <leader>f
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>lua require('telescope.builtin').find_files()<CR>";
        options.desc = "Find Files";
      }
      {
        mode = "n";
        key = "<leader>fd";
        action = ''
          <cmd>lua require('telescope.builtin').git_files({ cwd = require('telescope.utils').buffer_dir() })<CR>
        '';
        options.desc = "Find Files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>lua require('telescope.builtin').diagnostics()<CR>";
        options.desc = "Find Diagnostics";
      }

      # prefix: <leader>c
      {
        mode = "n";
        key = "<leader>cd";
        action = ''<cmd>Telescope lsp_definitions<CR>'';
        options.desc = "Definitions";
      }
      {
        mode = "n";
        key = "<leader>ct";
        action = ''<cmd>Telescope lsp_type_definitions<CR>'';
        options.desc = "Type Definitions";
      }
      {
        mode = "n";
        key = "<leader>cJ";
        action = ''<cmd>Telescope lsp_document_symbols<CR>'';
        options.desc = "Document symbols";
      }
      {
        mode = "n";
        key = "<leader>cj";
        action = ''<cmd>Telescope lsp_dynamic_workspace_symbols<CR>'';
        options.desc = "Workspace symbols";
      }
      {
        mode = "n";
        key = "<leader>cr";
        action = ''<cmd>Telescope lsp_references<CR>'';
        options.desc = "References";
      }
      {
        mode = "n";
        key = "<leader>cy";
        action = ''<cmd>Telescope lsp_incoming_calls<CR>'';
        options.desc = "Incoming calls";
      }
      {
        mode = "n";
        key = "<leader>cY";
        action = ''<cmd>Telescope lsp_outgoing_calls<CR>'';
        options.desc = "Incoming calls";
      }
      {
        mode = "n";
        key = "<leader>cx";
        action = ''<cmd>Telescope quickfix<CR>'';
        options.desc = "Quickfix";
      }

      # prefix: <leader>s
      {
        mode = "n";
        key = "<leader>s/";
        action = ''<cmd>Telescope search_history<CR>'';
        options.desc = "Search history";
      }
      {
        mode = "n";
        key = "<leader>su";
        action = ''<cmd>Telescope undo<CR>'';
        options.desc = "Undo";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action = ''<cmd>Telescope symbols<CR>'';
        options.desc = "Symbols";
      }
      {
        mode = "n";
        key = "<leader>st";
        action = ''<cmd>Telescope tags<CR>'';
        options.desc = "Tags";
      }
      {
        mode = "n";
        key = "<leader>sT";
        action = ''<cmd>Telescope tagstack<CR>'';
        options.desc = "Tagstack";
      }
      {
        mode = "n";
        key = "<leader>sm";
        action = "<cmd>Telescope marks<CR>";
        options.desc = "Marks";
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
        key = "<leader>gs";
        action = "<cmd>Telescope git_status<CR>";
        options.desc = "Git stash";
      }
      {
        mode = "n";
        key = "<leader>gS";
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
