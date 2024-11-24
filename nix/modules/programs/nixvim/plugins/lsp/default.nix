{
  imports = [
    ./lspsaga.nix
    ./lua_ls.nix
  ];

  programs.nixvim = {
    plugins = {
      lsp-format = {
        enable = true;
      };
      # none-ls = {
      #   enable = true;
      #   sources.code_actions = {
      #     gitrebase.enable = true;
      #     gitsigns.enable = true;
      #     refactoring.enable = true;
      #     impl.enable = true;
      #   # ts_node_action.enable = true;
      #   };
      #   # sources.completion = {
      #   #   luasnip.enable = true;
      #   #   clj_kondo.enable = true;
      #   # };
      #   sources.formatting = {
      #     just.enable = true;
      #   };
      # };
      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          awk_ls.enable = false;
          fennel_ls.enable = true;
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
        # NOTE: lspsaga provides its own keymaps
        # SEE: ./lspsaga.nix
        # SEE: https://nvimdev.github.io/lspsaga/
        keymaps = {
          silent = true;
          lspBuf = {
            gd = {
              action = "definition";
              desc = "Goto Definition";
            };
            gk = {
              action = "type_definition";
              desc = "Type Definition";
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
            "<leader>cr" = {
              action = "rename";
              desc = "Rename";
            };
          };
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
