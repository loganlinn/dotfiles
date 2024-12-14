local wezterm = require("wezterm")

return function(window, pane, uri)
  local url = wezterm.url.parse(uri)
  wezterm.log_info("parsed url", url)
  if url.scheme == "file" then
    -- window:perform_action(
    --   act.SpawnCommandInNewTab({
    --     cwd = util.dirname(url.file_path),
    --     args = { "zsh", "-c", 'yazi "$1"', "zsh", url.file_path },
    --     -- args = { "yazi", url.file_path },
    --   }),
    --   pane
    -- )
    wezterm.open_with(uri, "WezTerm")
    return false
  else
    wezterm.open_with(uri)
  end
end
