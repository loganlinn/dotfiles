{ pkgs, ... }:

let
  src = pkgs.fetchFromGitHub {
    owner = "chrisgrieser";
    repo = "nvim-early-retirement";
    rev = "9ae6fcc933fc865ddf2728460194b67985e06e27";
    hash = "sha256-ZjXG+POJFRsc79i1BuAJB9K6UBUfHT05oYvZaUr+RqA=";
  };
in
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          pname = src.repo;
          version = src.rev;
          inherit src;
          meta.homepage = "https://github.com/${src.owner}/${src.repo}/";
        };
      }
    ];
    extraConfigLua = ''
      require('early-retirement').setup({
        -- If a buffer has been inactive for this many minutes, close it.
        retirementAgeMins = 5,

        -- Filetypes to ignore.
        ignoredFiletypes = {},

        -- Ignore files matching this lua pattern; empty string disables this setting.
        ignoreFilenamePattern = "",

        -- Will not close the alternate file.
        ignoreAltFile = true,

        -- Minimum number of open buffers for auto-closing to become active. E.g.,
        -- by setting this to 4, no auto-closing will take place when you have 3
        -- or fewer open buffers. Note that this plugin never closes the currently
        -- active buffer, so a number < 2 will effectively disable this setting.
        minimumBufferNum = 1,
      })
    '';
  };
}
