{
  programs.nixvim = {
    plugins.mini = {
      enable = true;

      # Extend and create a/i textobjects
      modules.ai = {
        mappings = {
          # Table with textobject id as fields, textobject specification as values.
          # Also use this to disable builtin textobjects. See |MiniAi.config|.
          custom_textobjects = null;

          # Main textobject prefixes
          around = "a";
          inside = "i";

          # Next/last variants
          around_next = "an";
          inside_next = "in";
          around_last = "al";
          inside_last = "il";

          # Move cursor to corresponding edge of `a` textobject
          goto_left = "g[";
          goto_right = "g]";
        };
        # Number of lines within which textobject is searched
        n_lines = 50;
        # How to search for object (first inside current line, then inside
        # neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
        # 'cover_or_nearest', 'next', 'previous', 'nearest'.
        search_method = "cover_or_next";
      };

      modules.align = {
        mappings = {
          start = "ga";
          start_with_preview = "gA";
        };
      };

      modules.cursorword = { };

      modules.icons = { };

      modules.indentscope = { };

      modules.hipatterns = { };

      modules.sessions = { };

      modules.splitjoin = { };

      modules.surround = {
        mappings = {
          add = "gsa";
          delete = "gsd";
          find = "gsf";
          find_left = "gsF";
          highlight = "gsh";
          replace = "gsr";
          update_n_lines = "gsn";
        };
      };

      modules.starter = {
        content_hooks = {
          "__unkeyed-1.adding_bullet" = {
            __raw = "require('mini.starter').gen_hook.adding_bullet()";
          };
          "__unkeyed-2.indexing" = {
            __raw = "require('mini.starter').gen_hook.indexing('all', { 'Builtin actions' })";
          };
          "__unkeyed-3.padding" = {
            __raw = "require('mini.starter').gen_hook.aligning('center', 'center')";
          };
        };
        evaluate_single = true;
        header = ''
          ███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗
          ████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║
          ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║
          ██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║
          ██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║
        '';
        items = {
          "__unkeyed-1.buildtin_actions" = {
            __raw = "require('mini.starter').sections.builtin_actions()";
          };
          "__unkeyed-2.recent_files_current_directory" = {
            __raw = "require('mini.starter').sections.recent_files(10, false)";
          };
          "__unkeyed-3.recent_files" = {
            __raw = "require('mini.starter').sections.recent_files(10, true)";
          };
          "__unkeyed-4.sessions" = {
            __raw = "require('mini.starter').sections.sessions(5, true)";
          };
        };
      };
    };
  };
}
