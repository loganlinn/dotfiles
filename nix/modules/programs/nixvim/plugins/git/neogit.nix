{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.nixvim;
in
{
  programs.nixvim = {
    plugins.diffview = {
      enable = true;
    };
    plugins.neogit = {
      enable = true;
      settings = {
        graph_style = "unicode";
        git_services."github.com" =
          "https://github.com/\${owner}/\${repository}/compare/\${branch_name}?expand=1";
        git_services."gitlab.com" =
          "https://gitlab.com/\${owner}/\${repository}/merge_requests/new?merge_request[source_branch]=\${branch_name}";
        git_services."git.sr.ht" =
          "https://git.sr.ht/~\${owner}/\${repository}/send-email?branch=\${branch_name}";
        git_services."bitbucket.org" =
          "https://bitbucket.org/\${owner}/\${repository}/pull-requests/new?source=\${branch_name}&t=1";
        integrations.diffview = cfg.plugins.diffview.enable;
        integrations.telescope = cfg.plugins.telescope.enable;
      };
    };
  };
}
