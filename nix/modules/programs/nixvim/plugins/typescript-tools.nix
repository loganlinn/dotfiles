{
  programs.nixvim = {
    plugins.typescript-tools = {
      enable = true;
      settings = {
        settings = {
          separate_diagnostic_server = true;
          publish_diagnostic_on = "insert_leave";
          tsserver_max_memory = "auto";
          tsserver_locale = "en";
          complete_function_calls = false;
          include_completions_with_insert_text = true;
          code_lens = "off";
          disable_member_code_lens = true;
          jsx_close_tag = {
            enable = false;
            filetypes = [
              "javascriptreact"
              "typescriptreact"
            ];
          };
          tsserver_plugins = [
            "@styled/typescript-styled-plugin"
          ];
          tsserver_file_preferences.__raw = ''
            function(ft)
              -- Some "ifology" using `ft` of opened file
              return {
                includeInlayParameterNameHints = "all",
                includeCompletionsForModuleExports = true,
                quotePreference = "auto",
              }
            end
          '';
          # tsserver_format_options.__raw = ''
          #   function(ft)
          #     -- Some "ifology" using `ft` of opened file
          #     return {
          #       allowIncompleteCompletions = false,
          #       allowRenameOfImportPath = false,
          #     }
          #   end
          # '';
        };
      };
      handlers = {
        "textDocument/publishDiagnostics" = ''
          api.filter_diagnostics(
            -- Ignore 'This may be converted to an async function' diagnostics.
            { 80006 }
          )
        '';
      };
    };
  };
}
