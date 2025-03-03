{
  programs.nixvim = {
    plugins.lspsaga = {
      enable = true;

      beacon = {
        enable = true;
      };

      callhierarchy = {
        layout = "normal"; # default: "float"
        keys = {
          edit = "e";
          vsplit = "s";
          split = "i";
          tabe = "t";
          close = "<C-c>k";
          quit = "q";
          shuttle = "[w";
          toggleOrReq = "u";
        };
      };

      ui = {
        border = "rounded"; # One of none, single, double, rounded, solid, shadow
        codeAction = "💡"; # Can be any symbol you want 💡
      };

      hover = {
        openCmd = "!floorp"; # Choose your browser
        openLink = "gx";
      };

      diagnostic = {
        borderFollow = true;
        diagnosticOnlyCurrent = true;
        showCodeAction = true;
      };

      symbolInWinbar = {
        enable = true; # Breadcrumbs
      };

      codeAction = {
        extendGitSigns = false;
        showServerName = true;
        onlyInCursor = true;
        numShortcut = true;
        keys = {
          exec = "<cr>";
          quit = [
            "<Esc>"
            "q"
          ];
        };
      };

      lightbulb = {
        enable = false;
        sign = false;
        virtualText = true;
      };

      implement = {
        enable = true;
        virtualText = true;
      };

      rename = {
        inSelect = true; # Whether the name is selected when the float opens.
        autoSave = false; # Auto save file when the rename is done.
        projectMaxWidth = 0.6; # Width for the `project_replace` float window.
        projectMaxHeight = 0.4; # Height for the `project_replace` float window.
        keys = {
          exec = "<cr>";
          quit = [
            "<C-k>"
            "<Esc>"
            "<C-c>"
            "<C-g>"
          ];
          select = "x";
        };
      };

      outline = {
        autoClose = true;
        autoPreview = true;
        closeAfterJump = true;
        detail = true;
        layout = "normal"; # normal or float
        winPosition = "right"; # left or right
        winWidth = 50;
        maxHeight = 0.5;
        leftWidth = 0.3;
        keys = {
          jump = "e";
          quit = "q";
          toggleOrJump = "o";
        };
      };

      scrollPreview = {
        scrollDown = "<C-f>";
        scrollUp = "<C-b>";
      };
    };
    keymaps = [
      # {
      #   mode = "n";
      #   key = "gd";
      #   action = "<cmd>Lspsaga finder def<cr>";
      #   options = {
      #     desc = "Goto Definition";
      #     silent = true;
      #   };
      # }
      # {
      #   mode = "n";
      #   key = "gr";
      #   action = "<cmd>Lspsaga finder ref<cr>";
      #   options = {
      #     desc = "Goto References";
      #     silent = true;
      #   };
      # }
      # {
      #   mode = "n";
      #   key = "gD";
      #   action = "<cmd>Lspsaga show_line_diagnostics<cr>";
      #   options = {
      #     desc = "Goto Declaration";
      #     silent = true;
      #   };
      # }
      # {
      #   mode = "n";
      #   key = "gI";
      #   action = "<cmd>Lspsaga finder imp<cr>";
      #   options = {
      #     desc = "Goto Implementation";
      #     silent = true;
      #   };
      # }
      {
        mode = "n";
        key = "<leader>c*";
        action = "<cmd>Lspsaga finder ref<cr>";
        options = {
          desc = "Goto References";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>cI";
        action = "<cmd>Lspsaga finder imp<cr>";
        options = {
          desc = "Goto Implementation";
          silent = true;
        };
      }
      # {
      #   mode = "n";
      #   key = "gT";
      #   action = "<cmd>Lspsaga peek_type_definition<cr>";
      #   options = {
      #     desc = "Type Definition";
      #     silent = true;
      #   };
      # }
      {
        mode = "n";
        key = "K";
        action = "<cmd>Lspsaga hover_doc<cr>";
        options = {
          desc = "Hover";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>to";
        action = "<cmd>Lspsaga outline<cr>";
        options = {
          desc = "Outline";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>pr";
        action = "<cmd>Lspsaga project_replace<cr>";
        options = {
          desc = "Replace in project";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>cr";
        action = "<cmd>Lspsaga rename<cr>";
        options = {
          desc = "Rename";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>Lspsaga code_action<cr>";
        options = {
          desc = "Code Action";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>cd";
        action = "<cmd>Lspsaga show_cursor_diagnostics<cr>";
        options = {
          desc = "Line Diagnostics";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>cD";
        action = "<cmd>Lspsaga show_line_diagnostics<cr>";
        options = {
          desc = "Line Diagnostics";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "]e";
        action = "<cmd>Lspsaga diagnostic_jump_next<cr>";
        options = {
          desc = "Next Diagnostic";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "[e";
        action = "<cmd>Lspsaga diagnostic_jump_prev<cr>";
        options = {
          desc = "Previous Diagnostic";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "]E";
        action.__raw = ''
          function() require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR }) end
        '';
        options = {
          desc = "Next Diagnostic";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "[E";
        action.__raw = ''
          function() require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR }) end
        '';
        options = {
          desc = "Previous Diagnostic";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "F2";
        action = "<cmd>Lspsaga diagnostic_jump_next<cr>";
        options = {
          desc = "Next Diagnostic";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "S-F2";
        action = "<cmd>Lspsaga diagnostic_jump_prev<cr>";
        options = {
          desc = "Previous Diagnostic";
          silent = true;
        };
      }

      {
        mode = "v";
        key = "<leader>ot";
        action.__raw = ''
          function()
            local cwd = vim.fn.expand("%:p:h")
            if vim.env.WEZTERM_PANE then
              local wezterm_exe = vim.env.WEZTERM_EXECUTABLE or vim.fn.exepath("wezterm")
              vim.fn.system { weztgerm_exe, "cli", "split-pane", "--bottom",  "--cwd", cwd }
            else
              require('lspsaga.floaterm'):open_float_terminal(os.getenv('SHELL'), cwd)
            end
          end
        '';
        options.desc = "Terminal";
      }
    ];
  };
}
