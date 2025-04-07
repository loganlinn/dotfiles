{
  self,
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.programs.nixvim;
  inherit (import ../../helpers.nix { inherit lib; }) mkKeymap;
in
{
  imports = [
    ./lsp-format.nix
    ./lspsaga.nix
    ./lua_ls.nix
  ];

  programs.nixvim = {

    plugins.none-ls = {
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

    plugins.lspkind = {
      enable = true;
      cmp.enable = cfg.plugins.cmp.enable;
    };

    plugins.lsp = {
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
        lua_ls.enable = true; # see ./lua_ls.nix
        jsonls.enable = true;
        jqls.enable = true;
        # marksman.enable = true;
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
        pyright = {
          enable = true;
          settings = {
            # Use ruff for these
            disableOrganizeImports = true;
            python.analysis.ignore = [ "*" ];
          };
        };
        ruff = {
          enable = true;
          settings = { };
          onAttach.function = ''
            -- Defer to pyright for these
            client.server_capabilities.hoverProvider = false
          '';
        };
        sqls.enable = false;
        terraformls.enable = true;
        ts_ls.enable = false; # using plugins.typescript-tools instead
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
        extra = [
          {
            action = "<CMD>LspStop<CR>";
            key = "<leader>Lq";
          }
          {
            action = "<CMD>LspStart<CR>";
            key = "<leader>Ls";
          }
          {
            action = "<CMD>LspRestart<CR>";
            key = "<leader>Lr";
          }
          {
            action = "<CMD>LspLogs<CR>";
            key = "<leader>Ll";
          }
          {
            action = "<CMD>LspInfo<CR>";
            key = "<leader>LL";
          }
          {
            action = "<CMD>LspInfo<CR>";
            key = "<leader>hL";
          }
          (mkKeymap "n" "<leader>cf" "Format buffer" {
            __raw = ''function() vim.lsp.buf.format() end'';
          })
          (mkKeymap "v" "<leader>cf" "Format expr" {
            __raw = ''function() vim.lsp.formatexpr() end'';
          })
        ];
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
