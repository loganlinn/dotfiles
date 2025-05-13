{
  programs.nixvim = {
    plugins.snacks = {
      enable = true;
      settings = {
        bigfile.enable = true;
        debug.enable = true;
        # explorer.enable = true; # in future version
        git.enable = true;
        gitbrowse.enable = true;
        image.enable = true;
        indent.enable = true;
        notifier.enable = true;
        notify.enable = true;
        picker.enable = true;
        quickfile.enable = true;
        scratch.enable = true;
        statuscolumn.enable = true;
        toggle.enable = true;
        words.enable = true;
        zen.enable = true;
        # styles.notification.wo.wrap = true;
      };
    };
    keymaps = [
      # -- Pickers & Explorer
      {
        key = "<leader>,";
        action.__raw = ''function() Snacks.picker.buffers() end'';
        options.desc = "Buffers";
      }
      {
        key = "<leader>:";
        action.__raw = ''function() Snacks.picker.command_history() end'';
        options.desc = "Command History";
      }
      {
        key = "<leader>nn";
        action.__raw = ''function() Snacks.picker.notifications() end'';
        options.desc = "Notification History";
      }
      # {
      #   key = "<leader>fe";
      #   action.__raw = ''function() Snacks.explorer() end'';
      #   options.desc = "Explorer";
      # }
      {
        key = "<leader>f<space>";
        action.__raw = ''function() Snacks.picker.smart() end'';
        options.desc = "";
      }
      {
        key = "<leader>ft";
        action.__raw = ''function() Snacks.picker.files({ cwd = Snacks.git.get_root() }) end'';
        options.desc = "Top-level Files";
      }
      {
        key = "<leader>fg";
        action.__raw = ''function() Snacks.picker.git_files() end'';
        options.desc = "Top-level Files";
      }
      {
        key = "<leader>f.";
        action.__raw = ''function() Snacks.picker.files({ cwd = vim.env.DOTFILES_DIR or vim.fn.expand("~/.dotfiles") }) end'';
        options.desc = "Dotfiles";
      }
      {
        key = "<leader>pp";
        action.__raw = ''function() Snacks.picker.projects() end'';
        options.desc = "Projects";
      }
      {
        key = "<leader>fr";
        action.__raw = ''function() Snacks.picker.recent() end'';
        options.desc = "Recent";
      }
      # -- git
      {
        key = "<leader>gb";
        action.__raw = ''function() Snacks.picker.git_branches() end'';
        options.desc = "Branches";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>goo";
        action.__raw = ''function() Snacks.gitbrowse() end'';
        options.desc = "Browse Git URL";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>gY";
        action.__raw = ''
          function()
            Snacks.gitbrowse({
              open = function(url)
                vim.fn.setreg(vim.v.register or "+", url, "l")
                Snacks.notify.info("Yanked " .. url)
              end,
            })
          end
        '';
        options.desc = "Yank Git URL";
      }
      {
        key = "<leader>gl";
        action.__raw = ''function() Snacks.picker.git_log() end'';
        options.desc = "Log";
      }
      {
        key = "<leader>gL";
        action.__raw = ''function() Snacks.picker.git_log_line() end'';
        options.desc = "Log Line";
      }
      {
        key = "<leader>gs";
        action.__raw = ''function() Snacks.picker.git_status() end'';
        options.desc = "Status";
      }
      {
        key = "<leader>gf";
        action.__raw = ''function() Snacks.picker.git_log_file() end'';
        options.desc = "Log (File)";
      }
      # Search
      {
        key = "<leader>sb";
        action.__raw = ''function() Snacks.picker.lines() end'';
        options.desc = "Buffer Lines";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>sw";
        action.__raw = ''function() Snacks.picker.grep_word() end'';
        options.desc = "Search word";
      }
      {
        key = "<leader>s\"";
        action.__raw = ''function() Snacks.picker.registers() end'';
        options.desc = "Registers";
      }
      {
        key = "<leader>s.";
        action.__raw = ''function() Snacks.picker.grep_buffers({ cwd = vim.env.DOTFILES_DIR or vim.fn.expand("~/.dotfiles") }) end'';
        options.desc = "Search Dotfiles";
      }
      {
        key = "<leader>s/";
        action.__raw = ''function() Snacks.picker.search_history() end'';
        options.desc = "Search History";
      }
      {
        key = "<leader>s:";
        action.__raw = ''function() Snacks.picker.command_history() end'';
        options.desc = "Command History";
      }
      {
        key = "<leader>sc";
        action.__raw = ''function() Snacks.picker.commands() end'';
        options.desc = "Command";
      }
      {
        key = "<leader>sa";
        action.__raw = ''function() Snacks.picker.autocommands() end'';
        options.desc = "Autocommand";
      }
      {
        key = "<leader>se";
        action.__raw = ''function() Snacks.picker.diagnostics_buffer() end'';
        options.desc = "Diagnostic (Buffer)";
      }
      {
        key = "<leader>sE";
        action.__raw = ''function() Snacks.picker.diagnostics() end'';
        options.desc = "Diagnostic (All)";
      }
      {
        key = "<leader>sj";
        action.__raw = ''function() Snacks.picker.diagnostics() end'';
        options.desc = "Jump";
      }
      {
        key = "<leader>sh";
        action.__raw = ''function() Snacks.picker.help() end'';
        options.desc = "Help";
      }
      {
        key = "<leader>sH";
        action.__raw = ''function() Snacks.picker.highlights() end'';
        options.desc = "Highlight";
      }
      {
        key = "<leader>si";
        action.__raw = ''function() Snacks.picker.icons() end'';
        options.desc = "Icon";
      }
      {
        key = "<leader>sk";
        action.__raw = ''function() Snacks.picker.keymaps() end'';
        options.desc = "Keymap";
      }
      {
        key = "<leader>sl";
        action.__raw = ''function() Snacks.picker.loclist() end'';
        options.desc = "Location";
      }
      {
        key = "<leader>sm";
        action.__raw = ''function() Snacks.picker.marks() end'';
        options.desc = "Mark";
      }
      {
        key = "<leader>sM";
        action.__raw = ''function() Snacks.picker.man() end'';
        options.desc = "Man";
      }
      {
        key = "<leader>sq";
        action.__raw = ''function() Snacks.picker.qflist() end'';
        options.desc = "Quickfix";
      }
      {
        key = "<leader>su";
        action.__raw = ''function() Snacks.picker.undo() end'';
        options.desc = "Undo";
      }
      {
        key = "<leader>s`";
        action.__raw = ''function() Snacks.picker.resume() end'';
        options.desc = "Resume";
      }
      # -- LSP
      {
        key = "gd";
        action.__raw = ''function() Snacks.picker.lsp_definitions() end'';
        options.desc = "Goto Definition";
      }
      {
        key = "gD";
        action.__raw = ''function() Snacks.picker.lsp_declarations() end'';
        options.desc = "Goto Declaration";
      }
      {
        key = "gr";
        action.__raw = ''function() Snacks.picker.lsp_references() end'';
        options.desc = "Goto References";
      }
      {
        key = "gI";
        action.__raw = ''function() Snacks.picker.lsp_implementations() end'';
        options.desc = "Goto Implementation";
      }
      {
        key = "gy";
        action.__raw = ''function() Snacks.picker.lsp_type_definitions() end'';
        options.desc = "Goto T[y]pe Definition";
      }
      {
        key = "<leader>ss";
        action.__raw = ''function() Snacks.picker.lsp_symbols() end'';
        options.desc = "LSP Symbols";
      }
      {
        key = "<leader>sS";
        action.__raw = ''function() Snacks.picker.lsp_workspace_symbols() end'';
        options.desc = "LSP Symbols (Workspace)";
      }
      # -- Other
      {
        key = "<leader>tz";
        action.__raw = ''function() Snacks.zen() end'';
        options.desc = "Toggle Zen";
      }
      {
        key = "<leader>tb";
        action.__raw = ''function() Snacks.zen.zoom() end'';
        options.desc = "Toggle Zoom";
      }
      {
        key = "<leader>x";
        action.__raw = ''function() Snacks.scratch() end'';
        options.desc = "Toggle Scratch Buffer";
      }
      {
        key = "<leader>X";
        action.__raw = ''function() Snacks.scratch.select() end'';
        options.desc = "Select Scratch Buffer";
      }
      {
        key = "<leader>od";
        action.__raw = ''function() Snacks.picker.diagnostics_buffer() end'';
        options.desc = "Select Scratch Buffer";
      }
      # { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      # { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
      # { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      # { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      # { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
      # { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
      {
        mode = [
          "n"
          "t"
        ];
        key = "]]";
        action.__raw = ''function() Snacks.words.jump(vim.v.count1) end'';
        options.desc = "Next Reference";
      }
      {
        mode = [
          "n"
          "t"
        ];
        key = "[[";
        action.__raw = ''function() Snacks.words.jump(-vim.v.count1) end'';
        options.desc = "Prev Reference";
      }
    ];
    autoCmd = [
      {
        event = "VimEnter";
        pattern = "*";
        callback.__raw = ''
          function()
            -- Setup some globals for debugging
            _G.dd = function(...)
              Snacks.debug.inspect(...)
            end
            _G.bt = function()
              Snacks.debug.backtrace()
            end
            vim.print = _G.dd -- Override print to use snacks for `:=` command

            -- Create some toggle mappings
            Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>ts")
            Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
            Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>tr")
            Snacks.toggle.diagnostics():map("<leader>td")
            Snacks.toggle.line_number():map("<leader>tl")
            Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>tc")
            Snacks.toggle.treesitter():map("<leader>tT")
            Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>tb")
            Snacks.toggle.inlay_hints():map("<leader>th")
            -- NOTE: following cause NPE 
            -- Snacks.toggle.indent():map("<leader>tg")
            -- Snacks.toggle.dim():map("<leader>tD")
          end
        '';
      }
    ];
  };
}
