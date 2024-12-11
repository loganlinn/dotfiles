{
  self,
  inputs,
  config,
  ...
}:
let
  cfg = config.programs.nixvim;
in
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
      none-ls = {
        enable = true;
        enableLspFormat = true;
        sources.formatting = {
          shfmt.enable = true;
          just.enable = true;
        };
        settings = {
          diagnostic_config = { };
        };
      };
      lspkind = {
        enable = true;
        cmp.enable = cfg.plugins.cmp.enable;
      };
      lsp = {
        enable = true;
        inlayHints = true;
        servers = {
          awk_ls.enable = false;
          bashls.enable = true;
          eslint.enable = true;
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
          nil_ls.enable = false;
          nil_ls.settings = {
            # diagnostics.ignored = [ ];
            # formatting.command = [ "nixpkgs-fmt" ];
            # type.weakNilCheck = false;
            # nix.flake.autoArchive = null;
            # nix.flake.autoEvalInputs = true;
            # nix.flake.nixpkgsInputName = "nixpkgs";
            # nix.maxMemoryMB = 2500;
          };
          nixd.enable = true;
          nixd.settings = {
            formatting.command = [ "nixpkgs-fmt" ];
            diagnostic.suppress = [ "sema-escaping-with" ];
            nixpkgs.expr = ''import ${inputs.nixpkgs} {}'';
            options.flake.expr = ''(builtins.getFlake "${
              config.my.flakeDirectory or self
            }").currentSystem.options'';
          };
          prismals.enable = false;
          # pyright.enable = true;
          # pylsp.enable = true;
          ruff.enable = true;
          sqls.enable = true;
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
      -- local _border = "rounded"
      --
      -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      --   vim.lsp.handlers.hover, {
      --     border = _border
      --   }
      -- )
      --
      -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
      --   vim.lsp.handlers.signature_help, {
      --     border = _border
      --   }
      -- )
      --
      -- vim.diagnostic.config{
      --   float={border=_border}
      -- };
      --
      -- require('lspconfig.ui.windows').default_options = {
      --   border = _border
      -- }
    '';
  };
}
