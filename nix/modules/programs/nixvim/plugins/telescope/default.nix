{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (import ../../helpers.nix { inherit lib; }) mkKeymap;
in
{
  programs.nixvim = {
    # used by smart-open
    globals.sqlite_clib_path = "${pkgs.sqlite.out}/lib/libsqlite3.${
      if isDarwin then "dylib" else "so"
    }";

    extraPlugins = [
      pkgs.vimPlugins.smart-open-nvim
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
            "<C-u>" = {
              __raw = "false";
            }; # clear prompt
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
          grouped = true;
          select_buffer = true;
          collapse_dirs = true;
          use_fd = true;
          hidden.file_browser = true;
          hidden.folder_browser = true;
          path = "%:p:h";
          prompt_path = true;
          mappings = {
            i = {
              # "<Tab>" = ""; # TODO make this key go into directory :|
              "<D-bs>" = "remove";
              "<F2>" = "rename";
              "<F3>" = "move";
            };
            n = {
              "<D-bs>" = "remove";
              "<F3>" = "move";
              "<F2>" = "rename";
            };
          };
        };
      };
      extensions.frecency.enable = true;
      extensions.fzf-native.enable = false;
      extensions.fzy-native.enable = true;
      extensions.live-grep-args = {
        enable = true;
        settings = {
          auto_quoting = true;
          mappings = {
            i = {
              # "<C-'>" = mkRaw' ''require("telescope-live-grep-args.actions").quote_prompt()'';
              # "<C-->" = mkRaw' ''require("telescope-live-grep-args.actions").quote_prompt({ postfix = " -" })'';
              "<C-space>" = "to_fuzzy_refine";
            };
          };
        };
      };
      extensions.undo.enable = true;
      extensions.ui-select.enable = true;
      # extensions.manix.enable = true;
      keymaps = {
        "<leader>:" = "command_history";
        "<leader>'" = "resume";
        "<leader>bb" = "buffers"; # doom: project buffers
        "<leader><" = "buffers"; # doom: all buffers
        "<leader>bs" = "current_buffer_fuzzy_find";
        "<leader>bt" = "current_buffer_tags";
        "<leader>ff" = "file_browser";
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
        "<leader>s:" = {
          action = "command_history";
          options = {
            desc = "Command History";
          };
        };
        "<leader>hc" = {
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
      luaConfig.post = # lua
        ''
          require('telescope').load_extension('gh')
        '';
    };

    keymaps = [
      (mkKeymap "nv" "<leader><space>" "Find files" {
        __raw = ''function() require("telescope").extensions.smart_open.smart_open {  } end'';
      })
      (mkKeymap "nv" "<leader>fF" "Find from directory" {
        # __raw = ''function() require("telescope.builtin").find_files { cwd = vim.fn.expand("%:p:h") } end'';
        __raw = ''function() require("telescope").extensions.smart_open.smart_open { cwd_only = true } end'';
      })
      (mkKeymap "nv" "<leader>/" "Grep files" {
        __raw = ''function() require('telescope').extensions.live_grep_args.live_grep_args() end'';
      })
      (mkKeymap "n" "<leader>sb" "Grep word in buffer" {
        __raw = ''function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor_current_buffer() end'';
      })
      (mkKeymap "v" "<leader>sb" "Grep selection in buffer" {
        __raw = ''function() require("telescope-live-grep-args.shortcuts").grep_visual_selection_current_buffer() end'';
      })
      (mkKeymap "n" "<leader>*" "Grep word under cursor" {
        __raw = ''function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor() end'';
      })
      (mkKeymap "v" "<leader>*" "Grep selection in buffer" {
        __raw = ''function() require("telescope-live-grep-args.shortcuts").grep_visual_selection() end'';
      })
      (mkKeymap "nv" "<leader>cf" "Format buffer" {
        __raw = ''
          function()
            vim.lsp.buf.format({
              async = true,
              filter = function(client) return client.name ~= "ts_ls" end,
            })
          end'';
      })
      (mkKeymap "v" "<leader>ce" "LSP format expr" { __raw = ''function() vim.lsp.formatexpr() end''; })
      (mkKeymap "nv" "<leader>sd" "Search current directory" {
        __raw = ''
          function()
            require('telescope').extensions.live_grep_args.live_grep_args({
              search_dirs = { vim.fn.expand('%:p:h') }
            })
          end
        '';
      })
      (mkKeymap "n" "<leader>sd" "Grep current directory" {
        __raw = ''
          function()
            require('telescope').extensions.live_grep_args.live_grep_args({
              search_dirs = { vim.fn.expand('%:p:h') }
            })
          end
        '';
      })
      (mkKeymap "v" "<leader>sd" "Grep current directory" {
        __raw = ''
          function()
            require("telescope-live-grep-args.shortcuts").grep_visual_selection({
              search_dirs = { vim.fn.expand('%:p:h') }
            })
          end
        '';
      })
      # TODO use Telescope file_browser to select directory for seearch context
      # https://nix-community.github.io/nixvim/search/?query=telescope.extensions.file&option_scope=0&option=plugins.telescope.extensions.file-browser.settings.browse_folders
      (mkKeymap "nv" "<leader>sD" "Search other dir" {
        __raw = ''
          function()
          vim.ui.input(
            {
              prompt = 'Directory: ',
              default = vim.fn.expand('%:p:h')
            },
            function(search_dir)
              if #(search_dir or "") > 0 then
                require('telescope').extensions.live_grep_args.live_grep_args({
                  search_dirs = { search_dir }
                })
              end
            end)
          end
        '';
      })
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
