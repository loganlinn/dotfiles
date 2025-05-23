{
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  programs.nixvim = {
    plugins.obsidian = {
      # enable = true;
      settings = {
        completion = {
          min_chars = 2;
          nvim_cmp = true;
        };
        new_notes_location = "current_dir";
        dir = config.my.userDirs.notes;
        preferred_link_style = "markdown";
        use_advanced_uri = true;
        picker.name =
          if config.programs.nixvim.plugins.snacks.enable
          then "snacks.pick"
          else if config.programs.nixvim.plugins.mini.enable
          then "mini.pick"
          else if config.programs.nixvim.plugins.telescope.enable
          then "telescope.nvim"
          else null;
        templates.subdir = "System/Templates";
        callbacks.post_setup = null; # fun(client: obsidian.Client)
        callbacks.enter_note = null; # fun(client: obsidian.Client, note: obsidian.Note)
        callbacks.leave_note = null; # fun(client: obsidian.Client, note: obsidian.Note)
        callbacks.pre_write_note = null; # fun(client: obsidian.Client, note: obsidian.Note)
        callbacks.post_set_workspace = null; # fun(client: obsidian.Client, workspace: obsidian.Workspace)
        # follow_url_func = ''
        #   function(url)
        #     vim.fn.jobstart{ "${if isDarwin then "open" else "xdg-open"}", url }
        #   end
        # '';
        # image_name_func = ''
        #   function()
        #     -- Prefix image names with timestamp.
        #     return string.format("%s-", os.time())
        #   end
        # '';
        # markdown_link_func = ''
        #   function(opts)
        #     return string.format("[%s](%s)", opts.label, opts.path)
        #   end
        # '';
        # note_frontmatter_func = ''
        #   function(note)
        #     -- Add the title of the note as an alias.
        #     if note.title then
        #       note:add_alias(note.title)
        #     end
        #
        #     local out = { id = note.id, aliases = note.aliases, tags = note.tags }
        #
        #     -- `note.metadata` contains any manually added fields in the frontmatter.
        #     -- So here we just make sure those fields are kept in the frontmatter.
        #     if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        #       for k, v in pairs(note.metadata) do
        #         out[k] = v
        #       end
        #     end
        #
        #     return out
        #   end
        # '';
        # note_id_func = ''
        #   function(title)
        #     -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        #     -- In this case a note with the title 'My new note' will be given an ID that looks
        #     -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        #     local suffix = ""
        #     if title ~= nil then
        #       -- If title is given, transform it into valid file name.
        #       suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        #     else
        #       -- If title is nil, just add 4 random uppercase letters to the suffix.
        #       for _ = 1, 4 do
        #         suffix = suffix .. string.char(math.random(65, 90))
        #       end
        #     end
        #     return tostring(os.time()) .. "-" .. suffix
        #   end
        # '';
        log_level = "info";
      };
    };
  };
}
