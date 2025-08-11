{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nixvim;
in
{
  programs.nixvim = {
    nixpkgs.config.allowUnfree = true;
    dependencies = {
      claude-code.enable = false;
    };
    plugins.claude-code = {
      enable = true;
      lazyLoad.settings.cmd = [
        "ClaudeCode"
        "ClaudeCodeContinue"
        "ClaudeCodeResume"
        "ClaudeCodeVerbose"
      ];
      settings = {
        # window_navigation = true;
        # scrolling = true;
        # window = {
        #   position = "float";
        #   float = {
        #     width = "90%";
        #     height = "90%";
        #     row = "center";
        #     col = "center";
        #     relative = "editor";
        #     border = "rounded";
        #     # border = "single";
        #     # border = "double";
        #   };
        #   enter_insert = true;
        #   hide_numbers = true;
        #   hide_signcolumn = true;
        # };
        #
        # # File refresh settings
        # refresh = {
        #   enable = true;
        #   updatetime = 100;
        #   timer_interval = 1000;
        #   show_notifications = true;
        # };
        #
        # Git project settings
        git = {
          use_git_root = false;
        };
      };
    };
    plugins.which-key.settings.spec = lib.optionals cfg.plugins.claude-code.enable [
      {
        __unkeyed-1 = "<leader>ac";
        group = "Claude Code";
        icon = "";
      }
    ];
    keymaps = lib.mkIf cfg.plugins.claude-code.enable [
      {
        key = "<leader>act";
        action = "<cmd>ClaudeCode<CR>";
        options = {
          desc = "Toggle Claude";
        };
      }
      {
        key = "<leader>acc";
        action = "<cmd>ClaudeCodeContinue<CR>";
        options = {
          desc = "Continue Claude";
        };
      }
      {
        key = "<leader>acr";
        action = "<cmd>ClaudeCodeResume<CR>";
        options = {
          desc = "Resume Claude";
        };
      }
      {
        key = "<leader>acv";
        action = "<cmd>ClaudeCodeVerbose<CR>";
        options = {
          desc = "Verbose Claude";
        };
      }
    ];
    # keymaps = [
    #   {
    #     key = "<leader>ll";
    #     action = "<cmd>ClaudeCode<cr>";
    #     options = {
    #       desc = "Toggle Claude";
    #     };
    #   }
    #   {
    #     key = "<leader>lL";
    #     action = "<cmd>ClaudeCodeFocus<cr>";
    #     options = {
    #       desc = "Focus Claude";
    #     };
    #   }
    #   {
    #     key = "<leader>lr";
    #     action = "<cmd>ClaudeCode --resume<cr>";
    #     options = {
    #       desc = "Resume Claude";
    #     };
    #   }
    #   {
    #     key = "<leader>lC";
    #     action = "<cmd>ClaudeCode --continue<cr>";
    #     options = {
    #       desc = "Continue Claude";
    #     };
    #   }
    #   {
    #     key = "<leader>lb";
    #     action = "<cmd>ClaudeCodeAdd %<cr>";
    #     options = {
    #       desc = "Add current buffer";
    #     };
    #   }
    #   {
    #     mode = [ "v" ];
    #     key = "<leader>la";
    #     action = "<cmd>ClaudeCodeSend<cr>";
    #     options = {
    #       desc = "Send to Claude";
    #     };
    #   }
    #   # {
    #   #   key = "<leader>lf";
    #   #   action.__raw = ''''; # TODO pick file to add
    #   #   options = {
    #   #     desc = "Send to Claude";
    #   #   };
    #   # }
    #   {
    #     key = "<leader>lw";
    #     action = "<cmd>ClaudeCodeDiffAccept<cr>";
    #     options = {
    #       desc = "Accept diff";
    #     };
    #   }
    #   {
    #     key = "<leader>ld";
    #     action = "<cmd>ClaudeCodeDiffDeny<cr>";
    #     options = {
    #       desc = "Deny diff";
    #     };
    #   }
    # ];
    extraFiles."ftplugin/oil.lua".text = ''
      vim.keymap.set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = true, desc = "Add file" })
    '';
  };
}
