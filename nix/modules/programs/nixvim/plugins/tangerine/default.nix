{ pkgs, lib, ... }:
{
  programs.nixvim = {
    extraFiles."tangerine.nvim".source = pkgs.fetchFromGitHub {
      owner = "udayvir-singh";
      repo = "tangerine.nvim";
      rev = "885788fd96a2ac34e78dc4a58c1597494096f69c";
      hash = "sha256-kp7gaA02iO0WQJa3cZBKxbAvk4wv+Rg0RVZqwl7igbU=";
    };
  };
}
