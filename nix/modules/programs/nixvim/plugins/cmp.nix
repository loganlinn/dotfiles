{
  config,
  lib,
  ...
}: let
  cfg = config.programs.nixvim;
in {
  programs.nixvim = {
    plugins = {
      blink-cmp = {};
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
          disallow_fullfuzzy_matching = true;
          disallow_fuzzy_matching = true;
          disallow_partial_fuzzy_matching = true;
          disallow_partial_matching = false;
          disallow_prefix_unmatching = true;
          sorting.priority_weight = 2;
          sorting.comparators = let
            cmp-comparator = name:
            # lua
            ''require('cmp.config.compare').${name}'';
          in [
            (cmp-comparator "locality")
            (cmp-comparator "scopes")
            (cmp-comparator "offset")
            (cmp-comparator "exact")
            # #lua
            # ''
            #   function(entry1, entry2)
            #     local _, entry1_under = entry1.completion_item.label:find "^_+"
            #     local _, entry2_under = entry2.completion_item.label:find "^_+"
            #     return (entry1_under or 0) <= (entry2_under or 0)
            #   end
            # ''
            (cmp-comparator "score")
            (cmp-comparator "recently_used")
            (cmp-comparator "kind")
            (cmp-comparator "length")
            (cmp-comparator "order")
          ];

          experimental.ghost_text = true;

          snippet.expand =
            lib.optionalString cfg.plugins.cmp_luasnip.enable # lua
            
            ''function(args) require("luasnip").lsp_expand(args.body) end'';

          mapping.__raw = ''
            {
              ["<C-k>"] = cmp.mapping.select_prev_item(),
              ["<C-j>"] = cmp.mapping.select_next_item(),
              ["<C-d>"] = cmp.mapping.scroll_docs(-4),
              ["<C-f>"] = cmp.mapping.scroll_docs(4),
              ["<C-Space>"] = cmp.mapping.complete(),
              ["<C-e>"] = cmp.mapping.close(),
              ["<CR>"] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
              },
              ["<Tab>"] = cmp.mapping(function(fallback)
                local suggestion = require "supermaven-nvim.completion_preview"
                if suggestion.has_suggestion() then
                  suggestion.on_accept_suggestion()
                elseif cmp.visible() then
                  cmp.select_next_item()
                elseif require("luasnip").expand_or_jumpable() then
                  vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
                else
                  fallback()
                end
              end, {
                "i",
                "s",
              }),
              ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif require("luasnip").jumpable(-1) then
                  vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
                else
                  fallback()
                end
              end, {
                "i",
                "s",
              }),
              ["<C-p>"] = cmp.mapping.select_prev_item(),
              ["<C-n>"] = cmp.mapping.select_next_item(),
            }
          '';
          sources = [
            {
              name = "lazydev";
              group_index = 0;
            }
            {
              name = "nvim_lsp";
              max_item_count = 20;
              priority = 100;
            }
            {
              name = "nvim_lua";
              priority = 150;
            }
            {
              name = "path";
              keyword_length = 3;
            }
          ];
          formatting.fields = [
            "kind"
            "abbr"
            "menu"
          ];
          formatting.expandable_indicator = true;
          # formatting.format = # lua
          #   ''
          #     function(_, item)
          #       -- TODO use lspkind here?
          #       local icon = require('mini.icons').get("lsp", item.kind) or ""
          #       icon = cmp_ui.lspkind_text and tostring(icon) or icon
          #
          #       local kind = cmp_ui.lspkind_text and item.kind or ""
          #       item.kind = icon
          #       item.menu = kind
          #
          #       local MAX = 30
          #       if #item.abbr > MAX then
          #         item.abbr = item.abbr:sub(1, MAX - 1) .. " "
          #       else
          #         item.abbr = item.abbr .. string.rep(" ", MAX - #item.abbr)
          #       end
          #
          #       return item
          #     end
          #   '';
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
        vim.opt.shortmess:append "c" -- don't give ins-completion-menu messages

        local cmp = require'cmp'

        cmp.setup.cmdline({ "/", "?"}, {
          completion = {
            autocomplete = false, -- require tab to open
          },
          mapping = vim.tbl_deep_extend("force", cmp.mapping.preset.cmdline(), {
            ["<C-f>"] = {
              c = require("cmp.config.mapping").confirm { select = false },
            },
            ["<C-j>"] = {
              c = function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  fallback()
                end
              end,
            },
            ["<C-k>"] = {
              c = function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                else
                  fallback()
                end
              end,
            },
          }),
          window = { completion = cmp.config.window.bordered { col_offset = 0 } },
          formatting = { fields = { "abbr" } },
          sources = {
            { name = "buffer" },
          },
        })

      cmp.setup.cmdline(":", {
        completion = {
          autocomplete = false, -- require tab to open
        },
        mapping = vim.tbl_deep_extend("force", cmp.mapping.preset.cmdline(), {
          ["<C-f>"] = {
            c = require("cmp.config.mapping").confirm { select = false },
          },
          ["<C-j>"] = {
            c = function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end,
          },
          ["<C-k>"] = {
            c = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end,
          },
        }),
        window = { completion = cmp.config.window.bordered { col_offset = 0 } },
        formatting = { fields = { "abbr" } },
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

        cmp.setup.filetype('gitcommit', {
          sources = cmp.config.sources({
            { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
          }, {
          { name = 'buffer' },
          })
        })
    '';
  };
}
