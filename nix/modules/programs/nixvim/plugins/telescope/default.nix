{ pkgs, config, ... }:
let
  inherit (config.lib.nixvim) mkRaw;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  sqllite_clib_path = "${pkgs.sqlite.out}/lib/libsqlite3.${if isDarwin then "dylib" else "so"}";
in
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.smart-open-nvim;
        config = "let g:sqlite_clib_path = '${sqllite_clib_path}'";
      }
      pkgs.vimPlugins.telescope-zoxide
      pkgs.vimPlugins.telescope-github-nvim
    ];
    plugins.telescope = {
      enable = true;
      settings.defaults = {
        file_ignore_patterns = [
          "^.direnv/"
          "^.git/"
          "^__pycache__/"
          "^node_packages/"
          "^output/"
          "^target/"
        ];
        # keybindings _within_ telescope
        mappings = {
          i = {
            "<C-a>" = "which_key";
            "<C-h>" = "which_key";
            "<C-g>" = "close";
            "<C-u>" = mkRaw "false"; # clear prompt
            "<C-j>" = "move_selection_next";
            "<C-k>" = "move_selection_previous";
          };
        };
      };
      # https://github.com/nix-community/nixvim/tree/main/plugins/by-name/telescope/extensions
      extensions.file-browser = {
        enable = true;
        settings = {
          cwd_to_path = true;
          git_status = true;
        };
      };
      extensions.frecency.enable = true;
      extensions.fzf-native.enable = false;
      extensions.fzy-native.enable = true;
      extensions.live-grep-args.enable = true;
      extensions.undo.enable = true;
      extensions.ui-select.enable = true;
      # extensions.manix.enable = true;
      # extensions.ui-select.settings.codeactions = false;
      keymaps = {
        "<leader>:" = "command_history";
        "<leader>'" = "resume";
        "<leader>bb" = "buffers"; # doom: project buffers
        "<leader><" = "buffers"; # doom: all buffers
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
        "<leader>cx" = "diagnostics";
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
      luaConfig.post = ''
        require('telescope').load_extension('gh')
      '';
    };

    keymaps = [
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader><space>";
        options.desc = "Find files";
        action = mkRaw ''function() require("telescope").extensions.smart_open.smart_open() end'';
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>/";
        action = mkRaw ''
          function()
            require('telescope').extensions.live_grep_args.live_grep_args()
          end
        '';
        options.desc = "Grep Files";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>*";
        action = mkRaw ''
          function()
            require('telescope-live-grep-args.shortcuts').grep_visual_selection()
          end '';
        options.desc = "Grep Selection";
      }
      {
        mode = [
          "n"
        ];
        key = "<leader>cf";
        action = "<cmd>lua vim.lsp.buf.formatting()<CR>";
        options.desc = "Format buffer";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>sd";
        action = mkRaw ''
          function()
            require('telescope').extensions.live_grep_args.live_grep_args({
              search_dir = vim.fn.expand('%:p:h')
            })
          end'';
        options.desc = "Search current directory";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>sD";
        # TODO use Telescope file_browser to select directory for seearch context
        # https://nix-community.github.io/nixvim/search/?query=telescope.extensions.file&option_scope=0&option=plugins.telescope.extensions.file-browser.settings.browse_folders
        action = mkRaw ''
          function()
            vim.ui.input({ prompt = 'Directory: ', default = vim.fn.expand('%:p:h') }, function(search_dir)
              if #(search_dir or "") == 0 then return end
              require('telescope').extensions.live_grep_args.live_grep_args({
                search_dir = vim.fn.expand('%:p:h')
              })
            end)
          end
        '';
        options.desc = "Search other directory";
      }

      # prefix: <leader>f
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>ff";
        action = "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>";
        options.desc = "Find file";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>fF";
        action = mkRaw ''
          function()
            require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
          end
        '';
        options.desc = "Find current directory";
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
