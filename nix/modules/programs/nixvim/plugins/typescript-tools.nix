{
  programs.nixvim = {
    plugins.typescript-tools = {
      enable = true;
      # https://github.com/pmizio/typescript-tools.nvim/blob/master/lua/typescript-tools/config.lua
      settings = {
        settings = {
          separate_diagnostic_server = true;
          publish_diagnostic_on = "insert_leave";
          expose_as_code_action = "all";
          complete_function_calls = false;
          include_completions_with_insert_text = true;
          code_lens = "off";
          disable_member_code_lens = true;
          jsx_close_tag = {
            enable = true; # WARNING: conflicts with nvim-ts-autotag
            filetypes = [
              "javascriptreact"
              "typescriptreact"
            ];
          };
          # https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
          tsserver_locale = "en";
          tsserver_plugins = [
            "@styled/typescript-styled-plugin"
          ];
          tsserver_max_memory = 3120;
          tsserver_file_preferences = {
            allowTextChangesInNewFiles = true;
            disableLineTextInReferences = true;
            displayPartsForJSDoc = true;
            generateReturnInDocTemplate = true;
            importModuleSpecifierEnding = "auto";
            includeAutomaticOptionalChainCompletions = true;
            includeCompletionsForImportStatements = true;
            includeCompletionsForModuleExports = true;
            includeCompletionsWithClassMemberSnippets = true;
            includeCompletionsWithObjectLiteralMethodSnippets = true;
            includeCompletionsWithSnippetText = true;
            includeInlayEnumMemberValueHints = false;
            includeInlayFunctionLikeReturnTypeHints = false;
            includeInlayFunctionParameterTypeHints = false;
            includeInlayParameterNameHints = "all";
            includeInlayParameterNameHintsWhenArgumentMatchesName = false;
            includeInlayPropertyDeclarationTypeHints = false;
            includeInlayVariableTypeHints = false;
            includeInlayVariableTypeHintsWhenTypeMatchesName = false;
            jsxAttributeCompletionStyle = "auto";
            providePrefixAndSuffixTextForRename = true;
            provideRefactorNotApplicableReason = true;
            quotePreference = "auto";
            useLabelDetailsInCompletionEntries = true;
          };
          tsserver_format_options = {
            allowIncompleteCompletions = true;
            allowRenameOfImportPath = true;
            indentSwitchCase = true;
            insertSpaceAfterCommaDelimiter = true;
            insertSpaceAfterConstructor = false;
            insertSpaceAfterFunctionKeywordForAnonymousFunctions = true;
            insertSpaceAfterKeywordsInControlFlowStatements = true;
            insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true;
            insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false;
            insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true;
            insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false;
            insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false;
            insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false;
            insertSpaceAfterSemicolonInForStatements = true;
            insertSpaceAfterTypeAssertion = false;
            insertSpaceBeforeAndAfterBinaryOperators = true;
            insertSpaceBeforeFunctionParenthesis = false;
            placeOpenBraceOnNewLineForControlBlocks = false;
            placeOpenBraceOnNewLineForFunctions = false;
            semicolons = "ignore";
          };
        };
        handlers = {
          # "textDocument/publishDiagnostics" = ''
          #   api.filter_diagnostics(
          #     -- Ignore 'This may be converted to an async function' diagnostics.
          #     { 80006 }
          #   )
          # '';
        };
      };
    };
  };
}
