{ config, lib, ... }:
let
  cfg = config.programs.nixvim;
in
{
  programs.nixvim = {
    plugins = {
      cmp-nvim-lsp = {
        enable = true;
      };
      cmp-buffer = {
        enable = true;
      };
      cmp-path = {
        enable = true;
      };
      cmp-cmdline = {
        enable = true;
      };
      cmp_luasnip = {
        enable = false;
      };
      cmp = {
        enable = true;
        autoEnableSources = false;
        settings = {
          experimental = {
            ghost_text = true;
          };
          snippet.expand =
            lib.optionalString cfg.plugins.cmp_luasnip.enable # lua
              ''function(args) require("luasnip").lsp_expand(args.body) end'';
          mapping = {
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-p>" = ''cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select }''; # previous suggestion
            "<C-n>" = ''cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select }''; # next suggestion
            "<C-y>" = # lua
              ''
                cmp.mapping(
                  cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Insert,
                    select = true,
                  },
                  { "i", "c" }
                )
              '';
            # "<Tab>" = # lua
            #   ''
            #     cmp.mapping(function(fallback)
            #       if cmp.visible() then
            #         cmp.select_next_item()
            #       -- elseif luasnip.expand_or_jumpable() then
            #       --   luasnip.expand_or_jump()
            #       else
            #         fallback()
            #       end
            #     end, { "i", "s" })
            #   '';
            # "<S-Tab>" = # lua
            #   ''
            #     cmp.mapping(function(fallback)
            #       if cmp.visible() then
            #         cmp.select_prev_item()
            #       -- elseif luasnip.locally_jumpable(-1) then
            #       --   luasnip.jump(-1)
            #       else
            #         fallback()
            #       end
            #     end, { "i", "s" })
            #   '';
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = false })"; # Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            "<S-CR>" = ''cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })'';
          };
          sources = [
            # { name = "lazydev"; group_index = 0; }
            { name = "supermaven"; }
            { name = "nvim_lsp"; }
            {
              name = "buffer";
              keyword_length = 5;
            }
            {
              name = "path";
              keyword_length = 3;
            }
            # { name = "luasnip"; keyword_length = 3; }
          ];

          # Enable pictogram icons for lsp/autocompletion
          formatting = {
            fields = [
              "kind"
              "abbr"
              "menu"
            ];
            expandable_indicator = true;
          };
          performance = {
            debounce = 60;
            fetching_timeout = 200;
            max_view_entries = 30;
          };
          window = {
            completion = {
              border = "rounded";
              winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None";
            };
            documentation = {
              border = "rounded";
            };
          };
        };
      };
    };
    extraConfigLua = ''
      -- https://github.com/supermaven-inc/supermaven-nvim/issues/76
      vim.opt.completeopt = "menu,menuone,noselect"
      vim.opt.shortmess:append "c"

      -- local luasnip = require("luasnip")
      -- local lspkind = require("lspkind")
      -- kind_icons = {
      --   Text = "󰊄",
      --   Method = "",
      --   Function = "󰡱",
      --   Constructor = "",
      --   Field = "",
      --   Variable = "󱀍",
      --   Class = "",
      --   Interface = "",
      --   Module = "󰕳",
      --   Property = "",
      --   Unit = "",
      --   Value = "",
      --   Enum = "",
      --   Keyword = "",
      --   Snippet = "",
      --   Color = "",
      --   File = "",
      --   Reference = "",
      --   Folder = "",
      --   EnumMember = "",
      --   Constant = "",
      --   Struct = "",
      --   Event = "",
      --   Operator = "",
      --   TypeParameter = "",
      -- }

      local cmp = require'cmp'

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({'/', "?" }, {
        sources = {
          { name = 'buffer' }
        }
      })

      -- Set configuration for specific filetype.
      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
        }, {
        { name = 'buffer' },
        })
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
        { name = 'cmdline' }
        }),
      })  

      vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = "#44bdff" })
    '';
  };
}
