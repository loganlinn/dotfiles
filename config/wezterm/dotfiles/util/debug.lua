local wezterm = require("wezterm")

local M = {}

---@param arg any
---@return MuxWindow|nil
function M.get_mux_window(arg)
  if arg.gui_window then
    return arg
  end
  if arg.mux_window then
    return arg:mux_window()
  end
  if arg.window then
    return M.get_mux_window(arg:window())
  end
end

---@return MuxWindow
M.mux_window = function(arg)
  return M.get_mux_window(arg) or error("failed to get MuxWindow from " .. tostring(arg))
end

---@param arg any
---@return Window|nil
function M.get_gui_window(arg)
  if arg.gui_window then
    return arg:gui_window()
  end
  if arg.mux_window then
    return arg
  end
  if arg.window then
    return M.get_gui_window(arg:window())
  end
end

---@return Window
M.gui_window = function(arg)
  return M.get_gui_window(arg) or error("failed to get GuiWindow from " .. tostring(arg))
end

---@param window Window
---@param name string
---@return Key[]|nil
function M.get_key_table(window, name)
  local gui_window = M.get_gui_window(window) or error("no gui window")
  local config = gui_window:effective_config()
  if config.key_tables then
    return config.key_tables[name]
  end
end

M.dump_url = function(url)
  if not url then
    return
  elseif type(url) == "string" then
    url = wezterm.url.parse(url)
  else
    url = url
  end
  return {
    scheme = url.scheme,
    file_path = url.file_path,
    username = url.username,
    password = url.password,
    host = url.host,
    path = url.path,
    fragment = url.fragment,
    query = url.query,
  }
end

---@param proc_info LocalProcessInfo
M.dump_process = function(proc_info)
  if not proc_info then
    return
  end
  local children = {}
  for _, child in pairs(proc_info.children) do
    table.insert(children, M.dump_process(child))
  end
  return {
    pid = proc_info.pid, -- the process id
    ppid = proc_info.ppid, -- the parent process id
    name = proc_info.name, -- a short name for the process. Due to platform limitations, this may be inaccurate and truncated; you probably should prefer to look at the executable or argv fields instead of this one
    status = proc_info.status, -- a string holding the status of the process; it can be Idle, Run, Sleep, Stop, Zombie, Tracing, Dead, Wakekill, Waking, Parked, LockBlocked, Unknown.
    argv = proc_info.argv, -- a table holding the argument array for the process
    executable = proc_info.executable, -- the full path to the executable image for the process (may be empty)
    cwd = proc_info.cwd, -- the current working directory for the process (may be empty)
    children = children, -- a table keyed by child process id and whose values are themselves LocalProcessInfo objects that describe the child processes
  }
end

---@class PaneInformation
---@field index number the topological pane index
---@field is_active boolean a boolean indicating whether this is the active pane within the tab
---@field is_zoomed boolean a boolean indicating whether this pane is zoomed
---@field left number The offset from the top left corner of the containing tab to the top left corner of this pane, in cells.
---@field top number The offset from the top left corner of the containing tab to the top left corner of this pane, in cells.
---@field width number The width of this pane in cells
---@field height number The height of this pane in cells
---@field pixel_width number The width of this pane in pixels
---@field pixel_height number The height of this pane in pixels
---@field pane Pane

-- Resolve PaneInformation table via its tab.
---@param pane Pane
---@return PaneInformation
M.resolve_pane_info = function(pane)
  for _, pane_info in pairs(pane:tab():panes_with_info()) do
    if pane_info.pane:pane_id() == pane:pane_id() then
      return pane_info
    end
  end
end

local PANE_INFO_FIELDS =
  { "index", "is_active", "is_zoomed", "left", "top", "width", "height", "pixel_width", "pixel_height", "pane" }

M.is_pane_info = function(val)
  if type(val) ~= "userdata" then
    return false
  end
  for _, field in ipairs(PANE_INFO_FIELDS) do
    if val[field] == nil then
      return false
    end
  end
  return true
end

---@param PaneInformation
---@return table
M.dump_pane_info = function(pane_info)
  local data = {}
  for _, field in ipairs(PANE_INFO_FIELDS) do
    if field == "pane" then
      data[field] = M.dump_pane(pane_info[field])
    else
      data[field] = pane_info[field]
    end
  end
  return data
end

---@param pane Pane
---@return table
M.dump_pane = function(pane)
  return {
    pane_id = pane:pane_id(),
    current_working_dir = M.dump_url(pane:get_current_working_dir()),
    cursor_position = pane:get_cursor_position(),
    dimensions = pane:get_dimensions(),
    domain_name = pane:get_domain_name(),
    foreground_process_info = M.dump_process(pane:get_foreground_process_info()),
    foreground_process_name = pane:get_foreground_process_name(),
    metadata = pane:get_metadata(),
    title = pane:get_title(),
    tty_name = pane:get_tty_name(),
    user_vars = pane:get_user_vars(),
    has_unseen_output = pane:has_unseen_output(),
    is_alt_screen_active = pane:is_alt_screen_active(),
  }
end

---@param tab_info TabInformation
M.dump_tab_info = function(tab_info)
  local mux_tab = tab_info.tab or error("no tab")
  local panes = {}
  for _, pane_info in pairs(mux_tab:panes_with_info()) do
    table.insert(panes, M.dump_pane_info(pane_info))
  end
  return {
    index = tab_info.index,
    size = mux_tab:get_size(),
    title = mux_tab:get_title(),
    tab_id = mux_tab:tab_id(),
    is_active = tab_info.is_active,
    panes = panes,
  }
end

---@param win Window|MuxWindow
M.dump_window = function(win)
  local gui_win = M.get_gui_window(win) or error("no gui window")
  local mux_win = M.get_mux_window(win) or error("no mux window")
  local tabs = {}
  for _, tab_info in pairs(mux_win:tabs_with_info()) do
    table.insert(tabs, M.dump_tab_info(tab_info))
  end
  return {
    window_id = gui_win:window_id(),
    config_overrides = gui_win:get_config_overrides(),
    dimensions = gui_win:get_dimensions(),
    active_workspace = gui_win:active_workspace(),
    leader_is_active = gui_win:leader_is_active(),
    active_key_table = gui_win:active_key_table(),
    keyboard_modifiers = gui_win:keyboard_modifiers(),
    tabs = tabs,
  }
end

M.datafy = function(x)
  if type(x) ~= "userdata" then
    return x
  end
end

M.inspect = function(window, data, title)
  wezterm.log_info("dump", data)

  local json_encode = (wezterm.serde and wezterm.serde.json_encode_pretty)
    or wezterm.json_encode
    or error("json_encode function")

  local tab = M.mux_window(window):spawn_tab({
    args = { "zsh", "-l", "-c", [[ jless <<<"$1" || true ]], "-s", json_encode(data) },
  })

  tab:set_title(title or "inspect")
end

return M
