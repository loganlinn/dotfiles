{
  config,
  lib,
  ...
}: let
  inherit (config.lib.nixvim) listToUnkeyedAttrs;
  cfg = config.programs.nixvim;
  mkComponent = component: options: (listToUnkeyedAttrs [component]) // options;
in {
  programs.nixvim = {
    plugins.lualine = {
      enable = true;

      settings = {
        extensions = lib.concatLists [
          (lib.optional cfg.plugins.nvim-tree.enable "nvim-tree")
          (lib.optional cfg.plugins.fugitive.enable "fugitive")
          (lib.optional cfg.plugins.trouble.enable "trouble")
        ];

        # options = { };

        # +-------------------------------------------------+
        # | A | B | C                             X | Y | Z |
        # +-------------------------------------------------+

        # sections = {
        #   lualine_a = [ "mode" ];
        #   lualine_b = [ "branch" ];
        #   lualine_c = [
        #     "filename"
        #     "diff"
        #   ];
        #   lualine_x = [
        #     "diagnostics"
        #     (
        #       {
        #         __raw = ''
        #           function()
        #               local msg = ""
        #               local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
        #               local clients = vim.lsp.get_active_clients()
        #               if next(clients) == nil then
        #                   return msg
        #               end
        #               for _, client in ipairs(clients) do
        #                   local filetypes = client.config.filetypes
        #                   if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        #                       return client.name
        #                   end
        #               end
        #               return msg
        #           end
        #         '';
        #       }
        #       {
        #         icon = "";
        #         color.fg = "#ffffff";
        #       }
        #     )
        #     "encoding"
        #     "fileformat"
        #     "filetype"
        #   ];
        #   lualine_y = [
        #     (mkComponent "aerial" {
        #       cond.__raw = ''
        #         function()
        #           local buf_size_limit = 1024 * 1024
        #           if vim.api.nvim_buf_get_offset(0, vim.api.nvim_buf_line_count(0)) > buf_size_limit then
        #             return false
        #           end
        #
        #           return true
        #         end
        #       '';
        #       sep = " ) ";
        #       depth.__raw = "nil";
        #       dense = false;
        #       dense_sep = ".";
        #       colored = true;
        #     })
        #   ];
        #   lualine_z = [
        #     (mkComponent "location" { })
        #   ];
        # };

        # tabline = {
        #   lualine_a = [ (mkComponent "buffers" { symbols.alternate_file = ""; }) ];
        #   lualine_z = [ "tabs" ];
        # };

        # winbar = {
        #   lualine_x = [
        #     (mkComponent "filename" {
        #       path = 3;
        #       new_file_status = true;
        #       shorting_target = 150;
        #     })
        #   ];
        # };
      };
    };
  };
}
