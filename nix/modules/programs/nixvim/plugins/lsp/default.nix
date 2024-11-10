{
  imports = [ ./lspsaga.nix ];

  programs.nixvim = {
    plugins = {
      lsp-format = {
        enable = true;
      };
      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          awk_ls.enable = false;
          gopls.enable = true;
          html.enable = true;
          janet_lsp.enable = false;
          janet_lsp.package = null; # opt for installing janet-lsp as jpm dependency
          java_language_server.enable = false;
          lsp_ai.enable = false;
          lua_ls.enable = true;
          jsonls.enable = true;
          jqls.enable = true;
          marksman.enable = true;
          nixd.enable = true;
          prismals.enable = false;
          pyright.enable = true;
          terraformls.enable = true;
          ts_ls.enable = true;
          yamlls.enable = true;
        };
        keymaps = {
          silent = true;
          lspBuf = {
            gd = {
              action = "definition";
              desc = "Goto Definition";
            };
            gr = {
              action = "references";
              desc = "Goto References";
            };
            gD = {
              action = "declaration";
              desc = "Goto Declaration";
            };
            gI = {
              action = "implementation";
              desc = "Goto Implementation";
            };
            gT = {
              action = "type_definition";
              desc = "Type Definition";
            };
            # Use LSP saga keybinding instead
            # K = {
            #   action = "hover";
            #   desc = "Hover";
            # };
            # "<leader>cw" = {
            #   action = "workspace_symbol";
            #   desc = "Workspace Symbol";
            # };
            "<leader>cr" = {
              action = "rename";
              desc = "Rename";
            };
          };
          # diagnostic = {
          #   "<leader>cd" = {
          #     action = "open_float";
          #     desc = "Line Diagnostics";
          #   };
          #   "[d" = {
          #     action = "goto_next";
          #     desc = "Next Diagnostic";
          #   };
          #   "]d" = {
          #     action = "goto_prev";
          #     desc = "Previous Diagnostic";
          #   };
          # };
        };
      };
    };
    extraConfigLua = ''
      local _border = "rounded"

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = _border
        }
      )

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = _border
        }
      )

      vim.diagnostic.config{
        float={border=_border}
      };

      require('lspconfig.ui.windows').default_options = {
        border = _border
      }
    '';
  };
}
