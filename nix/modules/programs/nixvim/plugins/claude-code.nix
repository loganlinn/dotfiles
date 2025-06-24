{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.nixvim = {
    nixpkgs.config.allowUnfree = true;
    dependencies = {
      claude-code.enable = true;
    };
    plugins.claude-code = {
      enable = true;
    };
    keymaps = [
      {
        key = "<leader>ll";
        action = "<cmd>ClaudeCode<cr>";
        options = {
          desc = "Toggle Claude";
        };
      }
      {
        key = "<leader>lL";
        action = "<cmd>ClaudeCodeFocus<cr>";
        options = {
          desc = "Focus Claude";
        };
      }
      {
        key = "<leader>lr";
        action = "<cmd>ClaudeCode --resume<cr>";
        options = {
          desc = "Resume Claude";
        };
      }
      {
        key = "<leader>lC";
        action = "<cmd>ClaudeCode --continue<cr>";
        options = {
          desc = "Continue Claude";
        };
      }
      {
        key = "<leader>lb";
        action = "<cmd>ClaudeCodeAdd %<cr>";
        options = {
          desc = "Add current buffer";
        };
      }
      {
        mode = [ "v" ];
        key = "<leader>la";
        action = "<cmd>ClaudeCodeSend<cr>";
        options = {
          desc = "Send to Claude";
        };
      }
      # {
      #   key = "<leader>lf";
      #   action.__raw = ''''; # TODO pick file to add
      #   options = {
      #     desc = "Send to Claude";
      #   };
      # }
      {
        key = "<leader>lw";
        action = "<cmd>ClaudeCodeDiffAccept<cr>";
        options = {
          desc = "Accept diff";
        };
      }
      {
        key = "<leader>ld";
        action = "<cmd>ClaudeCodeDiffDeny<cr>";
        options = {
          desc = "Deny diff";
        };
      }
    ];
    extraFiles."ftplugin/oil.lua".text = ''
      vim.keymap.set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = true, desc = "Add file" })
    '';
  };
}
