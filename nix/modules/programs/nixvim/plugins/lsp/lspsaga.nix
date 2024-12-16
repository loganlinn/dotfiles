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
        keys = { };
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
          exec = "<CR>";
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
          exec = "<CR>";
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
      {
        mode = "n";
        key = "gd";
        action = "<cmd>Lspsaga finder def<CR>";
        options = {
          desc = "Goto Definition";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "gr";
        action = "<cmd>Lspsaga finder ref<CR>";
        options = {
          desc = "Goto References";
          silent = true;
        };
      }
      # {
      #   mode = "n";
      #   key = "gD";
      #   action = "<cmd>Lspsaga show_line_diagnostics<CR>";
      #   options = {
      #     desc = "Goto Declaration";
      #     silent = true;
      #   };
      # }
      {
        mode = "n";
        key = "gI";
        action = "<cmd>Lspsaga finder imp<CR>";
        options = {
          desc = "Goto Implementation";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>c*";
        action = "<cmd>Lspsaga finder ref<CR>";
        options = {
          desc = "Goto References";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>cI";
        action = "<cmd>Lspsaga finder imp<CR>";
        options = {
          desc = "Goto Implementation";
          silent = true;
        };
      }
      # {
      #   mode = "n";
      #   key = "gT";
      #   action = "<cmd>Lspsaga peek_type_definition<CR>";
      #   options = {
      #     desc = "Type Definition";
      #     silent = true;
      #   };
      # }
      {
        mode = "n";
        key = "K";
        action = "<cmd>Lspsaga hover_doc<CR>";
        options = {
          desc = "Hover";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>oc";
        action = "<cmd>Lspsaga outline<CR>";
        options = {
          desc = "Outline";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>co";
        action = "<cmd>Lspsaga outline<CR>";
        options = {
          desc = "Outline";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>pr";
        action = "<cmd>Lspsaga project_replace<CR>";
        options = {
          desc = "Replace in project";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>cr";
        action = "<cmd>Lspsaga rename<CR>";
        options = {
          desc = "Rename";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>Lspsaga code_action<CR>";
        options = {
          desc = "Code Action";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>cd";
        action = "<cmd>Lspsaga show_cursor_diagnostics<CR>";
        options = {
          desc = "Line Diagnostics";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>cD";
        action = "<cmd>Lspsaga show_line_diagnostics<CR>";
        options = {
          desc = "Line Diagnostics";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "[e";
        action = "<cmd>Lspsaga diagnostic_jump_next<CR>";
        options = {
          desc = "Next Diagnostic";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "]e";
        action = "<cmd>Lspsaga diagnostic_jump_prev<CR>";
        options = {
          desc = "Previous Diagnostic";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "[E";
        action.__raw = ''
          require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
        '';
        options = {
          desc = "Next Diagnostic";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "]E";
        action.__raw = ''
          require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
        '';
        options = {
          desc = "Previous Diagnostic";
          silent = true;
        };
      }
    ];
  };
}
