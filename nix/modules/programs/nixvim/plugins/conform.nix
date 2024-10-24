{
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      settings = {

        format_on_save = {
          lspFallback = true;
          timeoutMs = 500;
        };
        notify_on_error = true;

        formatters_by_ft =
          let
            prettier = [
              "prettierd"
              "prettier"
            ];
          in
          {
            html = [ prettier ];
            css = [ prettier ];
            javascript = [ prettier ];
            javascriptreact = [ prettier ];
            typescript = [
              prettier
            ];
            typescriptreact = [
              prettier
            ];
            python = [ "black" ];
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];
            markdown = [ prettier ];
            yaml = [
              "yamllint"
              "yamlfmt"
            ];
            terragrunt = [
              "hclfmt"
            ];
          };
      };
    };
  };
}
