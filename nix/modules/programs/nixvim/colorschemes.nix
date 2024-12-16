{
  programs.nixvim = {
    # colorschemes.dracula = {
    #   enable = false;
    #   # settings = {
    #   #   bold = true;
    #   #   colorterm = true;
    #   #   full_special_attrs_support = true;
    #   #   italic = true;
    #   #   underline = true;
    #   #   undercurl = true;
    #   #   strikethrough = true;
    #   # };
    # };

    # colorschemes.dracula-nvim = {
    #   enable = true;
    #   settings = {
    #     colors = {
    #       # bg = "#282A36";
    #       # fg = "#F8F8F2";
    #       # selection = "#44475A";
    #       # comment = "#6272A4";
    #       # red = "#FF5555";
    #       # orange = "#FFB86C";
    #       # yellow = "#F1FA8C";
    #       # green = "#50fa7b";
    #       # purple = "#BD93F9";
    #       # cyan = "#8BE9FD";
    #       # pink = "#FF79C6";
    #       # bright_red = "#FF6E6E";
    #       # bright_green = "#69FF94";
    #       # bright_yellow = "#FFFFA5";
    #       # bright_blue = "#D6ACFF";
    #       # bright_magenta = "#FF92DF";
    #       # bright_cyan = "#A4FFFF";
    #       # bright_white = "#FFFFFF";
    #       # menu = "#21222C";
    #       # visual = "#3E4452";
    #       # gutter_fg = "#4B5263";
    #       # nontext = "#3B4048";
    #       # white = "#ABB2BF";
    #       # black = "#191A21";
    #     };
    #     # show the '~' characters after the end of buffers
    #     show_end_of_buffer = true; # default false
    #     # use transparent background
    #     transparent_bg = true; # default false
    #     # set custom lualine background color
    #     lualine_bg_color = "#44475a";
    #     # set italic comment
    #     italic_comment = true; # default false
    #     # overrides the default highlights with table see `:h synIDattr`
    #     overrides = { };
    #   };
    # };

    # colorschemes.kanagawa = {
    #   enable = true;
    #   settings = {
    #     theme = "wave";
    #     keywordStyle.italic = false;
    #     commentStyle.italic = true;
    #     statementStyle.bold = false;
    #     overrides = { };
    #   };
    # };

    colorschemes.kanagawa = {
      enable = true;
      settings = {
        theme = "wave";

        colors = {
          palette = {
            fujiWhite = "#FFFFFF";
            sumiInk0 = "#000000";
          };
          theme = {
            all = {
              ui = {
                bg_gutter = "none";
              };
            };
            dragon = {
              syn = {
                parameter = "yellow";
              };
            };
            wave = {
              ui = {
                float = {
                  bg = "none";
                };
              };
            };
          };
        };

        commentStyle.italic = true;
        keywordStyle.italic = false;
        statementStyle.bold = false;
        functionStyle = { };

        compile = false;
        dimInactive = false;
        terminalColors = true;
        transparent = false;
        undercurl = true;

        overrides = "function(colors) return {} end";
      };
    };
  };
}
