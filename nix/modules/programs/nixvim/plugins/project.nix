{
  programs.nixvim = {
    plugins.project-nvim = {
      enable = true;
      enableTelescope = true;
      settings = {
        detection_methods = [
          "lsp"
          "pattern"
        ];
        patterns = [
          ".git"
          "_darcs"
          ".hg"
          ".bzr"
          ".svn"
          "Makefile"
          "package.json"
          "deps.edn"
          "pyproject.toml"
          "Cargo.toml"
          "go.mod"
        ];
        scope_chdir = "tab";
        show_hidden = true;
        silent_chdir = false;
      };
    };
  };
}
