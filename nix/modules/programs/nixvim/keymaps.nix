{ config, pkgs, ... }:
let
  inherit (config.lib.nixvim) mkRaw;
in
{
  # dependencies of keymap below
  programs.nixvim.extraPlugins = with pkgs.vimPlugins; [
    { plugin = vim-bbye; }
    { plugin = vim-eunuch; }
  ];

  programs.nixvim.keymaps = [
    # Disable arrow keys
    {
      mode = [
        "n"
        "i"
      ];
      key = "<Up>";
      action = "<Nop>";
      options = {
        silent = true;
        noremap = true;
        desc = "Disable Up arrow key";
      };
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<Down>";
      action = "<Nop>";
      options = {
        silent = true;
        noremap = true;
        desc = "Disable Down arrow key";
      };
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<Right>";
      action = "<Nop>";
      options = {
        silent = true;
        noremap = true;
        desc = "Disable Right arrow key";
      };
    }
    {
      mode = [
        "n"
        "i"
      ];
      key = "<Left>";
      action = "<Nop>";
      options = {
        silent = true;
        noremap = true;
        desc = "Disable Left arrow key";
      };
    }
    # Tabs
    {
      mode = "n";
      key = "<leader><tab><tab>";
      action = "<cmd>tabs<cr>";
      options = {
        silent = true;
        desc = "List tabs";
      };
    }
    {
      mode = "n";
      key = "<leader><tab><tab>";
      action = "<cmd>tabnew<cr>";
      options = {
        silent = true;
        desc = "New Tab";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>]";
      action = "<cmd>tabnext<cr>";
      options = {
        silent = true;
        desc = "Next Tab";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>d";
      action = "<cmd>tabclose<cr>";
      options = {
        silent = true;
        desc = "Close tab";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>[";
      action = "<cmd>tabprevious<cr>";
      options = {
        silent = true;
        desc = "Previous Tab";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>1";
      action = "<cmd>1gt<cr>";
      options = {
        silent = true;
        desc = "Go to tab 1";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>2";
      action = "<cmd>1gt<cr>";
      options = {
        silent = true;
        desc = "Go to tab 2";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>3";
      action = "<cmd>1gt<cr>";
      options = {
        silent = true;
        desc = "Go to tab 3";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>4";
      action = "<cmd>1gt<cr>";
      options = {
        silent = true;
        desc = "Go to tab 4";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>5";
      action = "<cmd>1gt<cr>";
      options = {
        silent = true;
        desc = "Go to tab 5";
      };
    }
    {
      mode = "n";
      key = "<leader><tab><lt>";
      action = "<cmd>-tabmove<cr>";
      options = {
        silent = true;
        desc = "Swap left";
      };
    }
    {
      mode = "n";
      key = "<leader><tab><gt>";
      action = "<cmd>+tabmove<cr>";
      options = {
        silent = true;
        desc = "Swap right";
      };
    }

    # Windows
    {
      mode = "n";
      key = "<leader>ww";
      action = "<C-W>p";
      options = {
        silent = true;
        desc = "Other window";
      };
    }
    {
      mode = "n";
      key = "<leader>wk";
      action = "<C-W>c";
      options = {
        silent = true;
        desc = "Kill window";
      };
    }
    {
      mode = "n";
      key = "<leader>wd";
      action = "<C-W>c";
      options = {
        silent = true;
        desc = "Kill window";
      };
    }
    {
      mode = "n";
      key = "<leader>ws";
      action = "<C-W>s";
      options = {
        silent = true;
        desc = "Split window below";
      };
    }
    {
      mode = "n";
      key = "<leader>wv";
      action = "<C-W>v";
      options = {
        silent = true;
        desc = "Split window right";
      };
    }
    {
      mode = "n";
      key = "<leader>w+";
      action = "<cmd>resize +2<cr>";
      options = {
        desc = "Increase height";
      };
    }
    {
      mode = "n";
      key = "<leader>w-";
      action = "<cmd>resize -2<cr>";
      options = {
        desc = "Decrease height";
      };
    }
    {
      mode = "n";
      key = "<leader>w<";
      action = "<cmd>vertical resize -2<cr>";
      options = {
        desc = "Decrease width";
      };
    }
    {
      mode = "n";
      key = "<leader>w>";
      action = "<cmd>vertical resize +2<cr>";
      options = {
        desc = "Increase width";
      };
    }
    {
      mode = "n";
      key = "<leader>wr";
      action = "<C-W>r";
      options = {
        silent = true;
        desc = "Rotate windows down/right";
      };
    }
    {
      mode = "n";
      key = "<leader>wR";
      action = "<C-W>R";
      options = {
        silent = true;
        desc = "Rotate windows up/left";
      };
    }
    {
      mode = "n";
      key = "<leader>wx";
      action = "<C-W>x";
      options = {
        silent = true;
        desc = "Exchange next window";
      };
    }

    # Quit/Session
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>quitall<cr><esc>";
      options = {
        silent = true;
        desc = "Quit all";
      };
    }
    {
      mode = "n";
      key = "<leader>qQ";
      action = "<cmd>quitall!<cr><esc>";
      options = {
        silent = true;
        desc = "Quit all!";
      };
    }

    # Toggle
    {
      mode = "n";
      key = "<leader>tl";
      action = ":lua ToggleLineNumber()<cr>";
      options = {
        silent = true;
        desc = "Toggle Line Numbers";
      };
    }

    {
      mode = "n";
      key = "<leader>tL";
      action = ":lua ToggleRelativeLineNumber()<cr>";
      options = {
        silent = true;
        desc = "Toggle Relative Line Numbers";
      };
    }

    {
      mode = "n";
      key = "<leader>tw";
      action = ":lua ToggleWrap()<cr>";
      options = {
        silent = true;
        desc = "Toggle Line Wrap";
      };
    }

    # Inlay Hints
    {
      mode = "n";
      key = "<leader>th";
      action = ":lua ToggleInlayHints()<cr>";
      options = {
        silent = true;
        desc = "Toggle Inlay Hints";
      };
    }

    # Movement
    {
      mode = "v";
      key = "J";
      action = ":m '>+1<cr>gv=gv";
      options = {
        silent = true;
        desc = "Move up when line is highlighted";
      };
    }
    {
      mode = "v";
      key = "K";
      action = ":m '<-2<cr>gv=gv";
      options = {
        silent = true;
        desc = "Move down when line is highlighted";
      };
    }
    {
      mode = "n";
      key = "J";
      action = "mzJ`z";
      options = {
        silent = true;
        desc = "Allow cursor to stay in the same place after appeding to current line";
      };
    }
    {
      mode = "v";
      key = "<";
      action = "<gv";
      options = {
        silent = true;
        desc = "Indent while remaining in visual mode.";
      };
    }
    {
      mode = "v";
      key = ">";
      action = ">gv";
      options = {
        silent = true;
        desc = "Indent while remaining in visual mode.";
      };
    }
    {
      mode = "n";
      key = "<C-d>";
      action = "<C-d>zz";
      options = {
        silent = true;
        desc = "Allow <C-d> and <C-u> to keep the cursor in the middle";
      };
    }
    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
      options = {
        desc = "Allow C-d and C-u to keep the cursor in the middle";
      };
    }
    #
    # Remap for dealing with word wrap and adding jumps to the jumplist.
    # {
    #   mode = "n";
    #   key = "j";
    #   action = mkRaw "[[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']]";
    #   options = {
    #     expr = true;
    #     desc = "Remap for dealing with word wrap and adding jumps to the jumplist.";
    #   };
    # }
    # {
    #   mode = "n";
    #   key = "k";
    #   action = mkRaw "[[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']]";
    #   options = {
    #     expr = true;
    #     desc = "Remap for dealing with word wrap and adding jumps to the jumplist.";
    #   };
    # }

    {
      mode = "n";
      key = "n";
      action = "nzzzv";
      options = {
        desc = "Allow search terms to stay in the middle";
      };
    }
    {
      mode = "n";
      key = "N";
      action = "Nzzzv";
      options = {
        desc = "Allow search terms to stay in the middle";
      };
    }

    # Paste stuff without saving the deleted word into the buffer
    {
      mode = "x";
      key = "<leader>p";
      action = "\"_dP";
      options = {
        desc = "Deletes to void register and paste over";
      };
    }

    # Copy stuff to system clipboard with <leader> + y or just y to have it just in vim
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>y";
      action = "\"+y";
      options = {
        desc = "Copy to system clipboard";
      };
    }

    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>Y";
      action = "\"+Y";
      options = {
        desc = "Copy to system clipboard";
      };
    }

    # Delete to void register
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>D";
      action = "\"_d";
      options = {
        desc = "Delete to void register";
      };
    }

    # <C-c> instead of pressing esc just because
    {
      mode = "i";
      key = "<C-c>";
      action = "<Esc>";
    }
    # For when I'm emacs-brained
    {
      mode = [
        "l"
        "n"
        "o"
        "v"
      ];
      key = "<C-g>";
      action = "<Esc>";
    }

    # Set highlight on search, but clear on pressing <Esc> in normal mode
    {
      mode = "n";
      key = "<Esc>";
      action = "<cmd>nohlsearch<cr>";
    }

    # {
    #   mode = "n";
    #   key = "<A-j>";
    #   action = "<cmd>m .+1<cr>==";
    #   options = {
    #     desc = "Move Down";
    #   };
    # }
    # {
    #   mode = "n";
    #   key = "<A-k>";
    #   action = "<cmd>m .-2<cr>==";
    #   options = {
    #     desc = "Move Up";
    #   };
    # }
    # {
    #   mode = "i";
    #   key = "<A-j>";
    #   action = "<esc><cmd>m .+1<cr>==gi";
    #   options = {
    #     desc = "Move Down";
    #   };
    # }
    # {
    #   mode = "i";
    #   key = "<A-k>";
    #   action = "<esc><cmd>m .-2<cr>==gi";
    #   options = {
    #     desc = "Move Up";
    #   };
    # }
    # {
    #   mode = "v";
    #   key = "<A-j>";
    #   action = ":m '>+1<cr>gv=gv";
    #   options = {
    #     desc = "Move Down";
    #   };
    # }
    # {
    #   mode = "v";
    #   key = "<A-k>";
    #   action = ":m '<-2<cr>gv=gv";
    #   options = {
    #     desc = "Move Up";
    #   };
    # }
    # {
    #   mode = "i";
    #   key = ";";
    #   action = ";<c-g>u";
    # }
    # {
    #   mode = "i";
    #   key = ".";
    #   action = ".<c-g>u";
    # }
    # {
    #   mode = "i";
    #   key = ";";
    #   action = ";<c-g>u";
    # }
    # {
    #   mode = [
    #     "i"
    #     "x"
    #     "n"
    #     "s"
    #   ];
    #   key = "<C-s>";
    #   action = "<cmd>w<cr><esc>";
    #   options = {
    #     desc = "Save File";
    #   };
    # }
    # {
    #   mode = [
    #     "i"
    #     "n"
    #   ];
    #   key = "<esc>";
    #   action = "<cmd>noh<cr><esc>";
    #   options = {
    #     desc = "Escape and Clear hlsearch";
    #   };
    # }
    # {
    #   mode = "n";
    #   key = "<leader>ur";
    #   action = "<cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><cr>";
    #   options = {
    #     desc = "Redraw / Clear hlsearch / Diff Update";
    #   };
    # }
    # {
    #   mode = "n";
    #   key = "n";
    #   action = "'Nn'[v:searchforward].'zv'";
    #   options = {
    #     expr = true;
    #     desc = "Next Search Result";
    #   };
    # }
    # {
    #   mode = "x";
    #   key = "n";
    #   action = "'Nn'[v:searchforward]";
    #   options = {
    #     expr = true;
    #     desc = "Next Search Result";
    #   };
    # }
    # {
    #   mode = "o";
    #   key = "n";
    #   action = "'Nn'[v:searchforward]";
    #   options = {
    #     expr = true;
    #     desc = "Next Search Result";
    #   };
    # }
    # {
    #   mode = "n";
    #   key = "N";
    #   action = "'nN'[v:searchforward].'zv'";
    #   options = {
    #     expr = true;
    #     desc = "Prev Search Result";
    #   };
    # }
    # {
    #   mode = "x";
    #   key = "N";
    #   action = "'nN'[v:searchforward]";
    #   options = {
    #     expr = true;
    #     desc = "Prev Search Result";
    #   };
    # }
    # {
    #   mode = "o";
    #   key = "N";
    #   action = "'nN'[v:searchforward]";
    #   options = {
    #     expr = true;
    #     desc = "Prev Search Result";
    #   };
    # }

    {
      mode = "n";
      key = "<leader>cd";
      action = "vim.diagnostic.open_float";
      options = {
        desc = "Line Diagnostics";
      };
    }
    {
      mode = "n";
      key = "]d";
      action = "diagnostic_goto(true)";
      options = {
        desc = "Next Diagnostic";
      };
    }
    {
      mode = "n";
      key = "[d";
      action = "diagnostic_goto(false)";
      options = {
        desc = "Prev Diagnostic";
      };
    }
    {
      mode = "n";
      key = "]e";
      action = "diagnostic_goto(true 'ERROR')";
      options = {
        desc = "Next Error";
      };
    }
    {
      mode = "n";
      key = "[e";
      action = "diagnostic_goto(false 'ERROR')";
      options = {
        desc = "Prev Error";
      };
    }
    {
      mode = "n";
      key = "]w";
      action = "diagnostic_goto(true 'WARN')";
      options = {
        desc = "Next Warning";
      };
    }
    {
      mode = "n";
      key = "[w";
      action = "diagnostic_goto(false 'WARN')";
      options = {
        desc = "Prev Warning";
      };
    }
    {
      mode = "n";
      key = "<leader>hp";
      action = "vim.show_pos";
      options = {
        desc = "Inspect Pos";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>n";
      action = "<cmd>tabnew<cr>";
      options = {
        desc = "New Tab";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>]";
      action = "<cmd>tabnext<cr>";
      options = {
        desc = "Next Tab";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>d";
      action = "<cmd>tabclose<cr>";
      options = {
        desc = "Close Tab";
      };
    }
    {
      mode = "n";
      key = "<leader><tab>[";
      action = "<cmd>tabprevious<cr>";
      options = {
        desc = "Previous Tab";
      };
    }
    {
      mode = "n";
      key = "<leader>b[";
      action = "<cmd>bprevious<cr>";
      options = {
        desc = "Previous Buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>`";
      action = "<cmd>b#<cr>";
      options = {
        silent = true;
        desc = "Last buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>b]";
      action = "<cmd>bnext<cr>";
      options = {
        desc = "Next Buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>gS";
      action = "<cmd>Gwrite<cr>";
      options = {
        desc = "Stage file";
      };
    }

    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>bk";
      action = "<cmd>Bwipeout<cr>"; # vim-bbye
      options.desc = "Kill buffer";
    }
    {
      key = "<leader>fD";
      action = mkRaw ''
        function()
          if 1 == vim.fn.confirm("Delete buffer and file?", "&Yes\n&No", 2) then
            local path = vim.fn.expand("%")
            vim.cmd("Bwipeout")
            local ok, err = os.remove(path)
            if ok then
              print("Deleted " .. path)
            else
              print("Error deleting " .. path .. ": " .. err)
            end
          end
        end
      '';
      options.desc = "Delete current file";
    }
    # TODO <leader>fR rename
    {
      key = "<leader>fR";
      action = mkRaw ''
        function()
          assert(vim.fn.exists(":Move"), "eunuch-:Move not found")
          local prompt = "Move to: "
          local default = vim.fn.expand("%:p:~")
          vim.ui.input({ prompt = prompt, default = default }, function(dest)
            if #(dest or "") == 0 then return end
            vim.cmd(":Move " .. dest)
          end)
        end
      '';
      options.desc = "Rename current file";
    }
    {
      key = "<leader>fM";
      action = mkRaw ''
        function()
          local file = vim.fn.expand("%")
          local current_mode = vim.fn.trim(vim.fn.system { "stat", "--format=%A", file })
          local prompt = string.format("chmod (%s): ", current_mode)
          vim.ui.input({ prompt = prompt }, function(input)
            if #(input or "") == 0 then return end
            if vim.fn.exists(":Chmod") then
              vim.cmd("Chmod " .. input)
            else
              print(vim.fn.system { "chmod", input, file })
            end
          end)
        end
      '';
      options.desc = "Change file mode";
    }
    {
      key = "<leader>fy";
      action = ''<cmd>let @+ = expand("%:.") <bar> echom "Copied! " . expand("%:.")<cr>'';
      options.desc = "Yank current file relative path";
    }
    {
      key = "<leader>fY";
      action = ''<cmd>let @+ = expand("%:p") <bar> echom "Copied! " . expand("%:p")<cr>'';
      options.desc = "Yank current file absolute path";
    }
    # Open stuff
    {
      key = "<leader>oe";
      action = mkRaw ''
        function()
          -- local line, column = TODO
          vim.fn.system {
            "emacsclient",
            "--no-wait",
            -- string.format("+%n:%n", line, column),
            vim.fn.expand("%:p")
          }
        end
      '';
      options.desc = "Open file in Emacs";
    }
  ];
}
