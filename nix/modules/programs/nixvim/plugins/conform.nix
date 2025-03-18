{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  inherit (config.lib.nixvim) listToUnkeyedAttrs;
in
{
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      settings = {
        notify_on_error = true;
        notify_no_formatters = false;
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
        default_format_opts = {
          lsp_format = "fallback";
          timeout_ms = 2000;
        };
        formatters_by_ft =
          let
            prettier =
              (listToUnkeyedAttrs [
                "prettierd"
                "prettier"
              ])
              // {
                stop_after_first = true;
              };
          in
          {
            bash = [
              "shellcheck"
              "shellharden"
              "sfmt"
            ];
            crystal = [ "crystal" ];
            clojure = [ "cljfmt" ];
            cpp = [ "clang_format" ];
            css = prettier;
            fennel = [ "fnlfmt" ];
            gleam = [ "gleam" ];
            go = [
              "goimports"
              "gofmt"
            ];
            hcl = [ "hcl" ];
            html = prettier;
            javascript = prettier;
            just = [ "just" ];
            lua = [ "stylua" ];
            markdown = [
              "prettier"
              "injected"
            ];
            proto = [ "buf" ];
            python = [
              "ruff_format"
              "ruff_organize_imports"
            ];
            nix = [ "nixfmt" ];
            rust = [ "rustfmt" ];
            sql = [ "sqlfluff" ];
            terraform = [ "terraform_fmt" ];
            toml = [ "taplo" ];
            typescript = prettier;
            typescriptreact = prettier;
            yaml = prettier;
            "*" = [ "typos" ];
            "_" = [ "trim_whitespace" ];
          };
        formatters = {
          fnlfmt.command = getExe pkgs.fnlfmt;
          goimpports.command = getExe' pkgs.gotools "goimports";
          hcl.command = getExe pkgs.hclfmt;
          injected.ignore_errors = true;
          prettierd.command = getExe pkgs.prettierd;
          ruff_format.command = getExe pkgs.ruff;
          ruff_organize_imports.command = getExe pkgs.ruff;
          shellcheck.command = getExe pkgs.shellcheck;
          shellharden.command = getExe pkgs.shellharden;
          shfmt.command = getExe pkgs.shfmt;
          sqlfluff.command = getExe pkgs.sqlfluff;
          squeeze_blanks.command = getExe' pkgs.coreutils "cat";
          stylua.command = getExe pkgs.stylua;
          taplo.command = getExe pkgs.taplo;
          typos.command = getExe pkgs.typos;
        };
      };
    };
  };
}
