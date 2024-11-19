[
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
    key = "<leader><tab>`";
    action = "<cmd>b#<cr>";
    options = {
      silent = true;
      desc = "Last buffer";
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
    key = "<leader>wd";
    action = "<C-W>c";
    options = {
      silent = true;
      desc = "Delete window";
    };
  }

  {
    mode = "n";
    key = "<leader>w-";
    action = "<C-W>s";
    options = {
      silent = true;
      desc = "Split window below";
    };
  }

  {
    mode = "n";
    key = "<leader>w|";
    action = "<C-W>v";
    options = {
      silent = true;
      desc = "Split window right";
    };
  }

  {
    mode = "n";
    key = "<C-s>";
    action = "<cmd>w<cr><esc>";
    options = {
      silent = true;
      desc = "Save file";
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
  {
    mode = "n";
    key = "j";
    action.__raw = "
        [[(v:count > 1 ? 'm`' . v:count : 'g') . 'j']]
      ";
    options = {
      expr = true;
      desc = "Remap for dealing with word wrap and adding jumps to the jumplist.";
    };
  }
  {
    mode = "n";
    key = "k";
    action.__raw = "
        [[(v:count > 1 ? 'm`' . v:count : 'g') . 'k']]
      ";
    options = {
      expr = true;
      desc = "Remap for dealing with word wrap and adding jumps to the jumplist.";
    };
  }

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

  {
    mode = "n";
    key = "<C-f>";
    action = "!tmux new tmux-sessionizer<cr>";
    options = {
      desc = "Switch between projects";
    };
  }

  # Set highlight on search, but clear on pressing <Esc> in normal mode
  {
    mode = "n";
    key = "<Esc>";
    action = "<cmd>nohlsearch<cr>";
  }

  # {
  #   mode = "n";
  #   key = "<C-Up>";
  #   action = "<cmd>resize +2<cr>";
  #   options = {
  #     desc = "Increase Window Height";
  #   };
  # }
  # {
  #   mode = "n";
  #   key = "<C-Down>";
  #   action = "<cmd>resize -2<cr>";
  #   options = {
  #     desc = "Decrease Window Height";
  #   };
  # }
  # {
  #   mode = "n";
  #   key = "<C-Left>";
  #   action = "<cmd>vertical resize -2<cr>";
  #   options = {
  #     desc = "Decrease Window Width";
  #   };
  # }
  # {
  #   mode = "n";
  #   key = "<C-Right>";
  #   action = "<cmd>vertical resize +2<cr>";
  #   options = {
  #     desc = "Increase Window Width";
  #   };
  # }
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
  # {
  #   mode = "t";
  #   key = "<esc><esc>";
  #   action = "<c-\\><c-n>";
  #   options = {
  #     desc = "Enter Normal Mode";
  #   };
  # }
  # {
  #   mode = "t";
  #   key = "<C-h>";
  #   action = "<cmd>wincmd h<cr>";
  #   options = {
  #     desc = "Go to Left Window";
  #   };
  # }
  # {
  #   mode = "t";
  #   key = "<C-j>";
  #   action = "<cmd>wincmd j<cr>";
  #   options = {
  #     desc = "Go to Lower Window";
  #   };
  # }
  # {
  #   mode = "t";
  #   key = "<C-k>";
  #   action = "<cmd>wincmd k<cr>";
  #   options = {
  #     desc = "Go to Upper Window";
  #   };
  # }
  # {
  #   mode = "t";
  #   key = "<C-l>";
  #   action = "<cmd>wincmd l<cr>";
  #   options = {
  #     desc = "Go to Right Window";
  #   };
  # }
  # {
  #   mode = "t";
  #   key = "<C-/>";
  #   action = "<cmd>close<cr>";
  #   options = {
  #     desc = "Hide Terminal";
  #   };
  # }
  # {
  #   mode = "n";
  #   key = "<leader>ww";
  #   action = "<C-W>p";
  #   options = {
  #     desc = "Other Window";
  #     remap = true;
  #   };
  # }
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
    action = "<cmd>bprevious<cr>";
    options = {
      desc = "Previous Buffer";
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
    key = "<leader>fD";
    action.__raw = ''
      function()
        if 1 == vim.fn.confirm("Delete buffer and file?", "&Yes\n&No", 2) then
          local path = vim.fn.expand("%")
          local ok, err = os.remove(path)
          if ok then
            vim.api.nvim_buf_delete(0, { force = true })
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
    key = "<leader>fy";
    action = ''<cmd>let @+ = expand("%:.")'';
    options.desc = "Yank current file relative path";
  }
  {
    key = "<leader>fY";
    action = ''<cmd>let @+ = expand("%:p")'';
    options.desc = "Yank current file absolute path";
  }
  {
    key = "<leader>fM";
    action.__raw = ''
      function()
        vim.ui.input({
          prompt = "File mode: (octal or symbolic) ",
        }, function(input)
          if input then
            local shellescape = vim.fn.shellescape
            local command = "chmod " .. shellescape(input) .. " " .. shellescape(vim.fn.expand("%:p"))
            local result = os.execute(command)
            print(command .. " => " .. result)
          end
        end)
      end
    '';
    options.desc = "Yank current file absolute path";
  }
]
