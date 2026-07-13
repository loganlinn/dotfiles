{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.nixvim;
in {
  programs.nixvim = {
    extraPlugins = lib.optionals cfg.plugins.copilot-lua.enable (
      with pkgs.vimPlugins;
        lib.optionals cfg.plugins.lualine.enable [
          copilot-lualine
        ]
    );

    lsp.servers.copilot = {
      enable = cfg.plugins.copilot-lua.enable && cfg.plugins.copilot-lua.settings.nes.enabled;
    };

    # plugins.blink-cmp-copilot = {
    #   enable = cfg.plugins.copilot-lua.enable && cfg.plugins.blink-cmp.enable;
    # };

    plugins.copilot-lua = {
      lazyLoad.settings.event = ["InsertEnter"];
      settings = {
        nes = {
          enabled = true;
          keymap = {
            accept_and_goto = "<TAB>";
            accept = false;
            dismiss = "<Esc>";
          };
        };
        suggestion = {
          enabled = !cfg.plugins.blink-cmp.enable;
          auto_trigger = true;
          debounce = 90;
          hide_during_completion = false;
          keymap = {
            accept = "<C-y>";
            accept_word = false; # "<M-w>";
            accept_line = false; # "<M-e>";
            next = "<M-]>";
            prev = "<M-[>";
            dismiss = "<C-n>";
          };
        };
        panel = {
          enabled = !cfg.plugins.blink-cmp.enable;
          auto_refresh = true;
          keymap = {
            jump_prev = "[[";
            jump_next = "]]";
            accept = "<cr>";
            refresh = "gr";
            open = "<M-CR>";
          };
          layout = {
            position = "bottom";
            ratio = 0.4;
          };
        };
        filetypes = {
          help = false;
          gitrebase = false;
          # gitcommit = false;
        };
      };
    };

    plugins.copilot-chat = {
      enable = cfg.plugins.copilot-lua.enable;
      lazyLoad.settings = {
        enable = true;
        cmd = [
          "CopilotChat"
          "CopilotChatAgents"
          "CopilotChatLoad"
          "CopilotChatModels"
          "CopilotChatOpen"
          "CopilotChatPrompts"
          "CopilotChatToggle"
        ];
        event = [
          "BufReadPost"
          "BufWritePost"
          "BufNewFile"
        ];
      };
    };

    plugins.which-key.settings.spec = lib.optionals cfg.plugins.copilot-chat.enable [
      {
        __unkeyed-1 = "<leader>aC";
        group = "Copilot";
        icon = "";
      }
    ];

    keymaps = lib.mkIf cfg.plugins.copilot-chat.enable [
      {
        mode = "n";
        key = "<leader>aCa";
        action = "<cmd>CopilotChatAgents<CR>";
        options = {
          desc = "List Available Agents";
        };
      }
      {
        mode = "n";
        key = "<leader>aCc";
        action = "<cmd>CopilotChatClose<CR>";
        options.desc = "Close Chat";
      }
      {
        mode = "n";
        key = "<leader>aCl";
        action = "<cmd>CopilotChatLoad<CR>";
        options = {
          desc = "Load Chat History";
        };
      }
      {
        mode = "n";
        key = "<leader>aCm";
        action = "<cmd>CopilotChatModels<CR>";
        options = {
          desc = "List Available Models";
        };
      }
      {
        mode = "n";
        key = "<leader>aCo";
        action = "<cmd>CopilotChatOpen<CR>";
        options.desc = "Open Chat";
      }
      {
        mode = "n";
        key = "<leader>aCp";
        action.__raw = ''
          function()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
          end
        '';
        options = {
          desc = "Prompt Actions";
        };
      }
      {
        mode = "n";
        key = "<leader>aCP";
        action = "<cmd>CopilotChatPrompts<CR>";
        options.desc = "Select Prompt";
      }
      {
        mode = "n";
        key = "<leader>aCq";
        action.__raw = ''
          function()
            local input = vim.fn.input("Quick Chat: ")
            if input ~= "" then
              require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
            end
          end
        '';
        options = {
          desc = "Quick Chat";
        };
      }
      {
        mode = "n";
        key = "<leader>aCs";
        action = "<cmd>CopilotChatStop<CR>";
        options.desc = "Stop Chat";
      }
      {
        mode = "n";
        key = "<leader>aCS";
        action = "<cmd>CopilotChatSave<CR>";
        options.desc = "Save Chat";
      }
      {
        mode = "n";
        key = "<leader>aCr";
        action = "<cmd>CopilotChatReset<CR>";
        options.desc = "Reset Chat";
      }
      {
        mode = "n";
        key = "<leader>aCt";
        action = "<cmd>CopilotChatToggle<CR>";
        options = {
          desc = "Toggle Chat Window";
        };
      }
    ];

    # TODO: conditional on blink-cmp enabled
    autoCmd = lib.mkIf cfg.plugins.copilot-lua.enable [
      {
        event = "User";
        pattern = "BlinkCmpMenuOpen";
        callback.__raw = ''
          function()
            vim.b.copilot_suggestion_hidden = true
          end
        '';
      }
      {
        event = "User";
        pattern = "BlinkCmpMenuClose";
        callback.__raw = ''
          function()
            vim.b.copilot_suggestion_hidden = false
          end
        '';
      }
    ];
  };
}
